#!/usr/bin/env python3
"""
TASK-LOOP v2 daemon — single-writer-per-file board + context-bridging worker dispatch.

See ~/.claude/TASKLOOP2.md for the protocol. The big change from v1: the daemon NEVER
rewrites the file the user types in. Three files joined by an id:
  - TASKS.md  (user writes; daemon reads; daemon's only write is a fallback id-stamp)
  - STATUS.md (daemon regenerates; user reads)
  - REVIEW.md (user writes verdicts `#NN gg|<note>|?q`; daemon reads; never writes)
Daemon state (ids, per-task thread, file->task touch index, consumed verdicts, accepted
log) lives in .taskloop/state.json. Single instance via a lifetime flock. Kill switch:
pkill -f task-loop-daemon2.py

PARALLEL EXECUTION (v2.1): workers run concurrently up to MAX_WORKERS, scheduled by a
file-lock model so two workers never edit the same file at once. Each task carries a
`claim` = the set of repo-relative files it will edit. Claims come from, in order:
  1. a declared `files: a.ts, b.ts` line in the task body  (free, exact)
  2. a fast read-only SCOPE pass (claude -p, plan mode) that lists the files  (auto)
  3. exclusive fallback — claim unknown -> the task runs ALONE (serial-equivalent)
A task is dispatched only when its claim is disjoint from every in-flight worker's claim;
otherwise it waits (surfaced in STATUS.md with the conflicting file + holder). Enforcement
is soft (the worker is told to edit only its claim) plus a collision backstop: if a
finished worker reports editing a file another live worker holds, the task is flagged for
re-verify. Exclusive (unknown-claim) tasks head-of-line block to avoid starvation.

Usage: python3 task-loop-daemon2.py <repo-root> [--tasks TASKS.md] [--dry-run]
       [--max-workers N] [--max-scopers N]
"""
import os, sys, re, glob, json, time, signal, subprocess, datetime, fcntl, hashlib, traceback

# ---- paths / config -------------------------------------------------------
ARGV = sys.argv[1:]
ROOT = next((a for a in ARGV if not a.startswith("--")), os.getcwd())
DRY = "--dry-run" in ARGV
def _opt(name, default):
    for i, a in enumerate(ARGV):
        if a == name and i + 1 < len(ARGV):
            return ARGV[i + 1]
    return default
TASKS  = os.path.join(ROOT, _opt("--tasks", "TASKS.md"))
STATUS = os.path.join(ROOT, _opt("--status", "STATUS.md"))
REVIEW = os.path.join(ROOT, _opt("--review", "REVIEW.md"))
DIR    = os.path.join(ROOT, ".taskloop")
ASSETS = os.path.join(ROOT, ".task-assets")
STATE_F     = os.path.join(DIR, "state.json")
WORKERS_DIR = os.path.join(DIR, "workers")        # one lock file per running exec worker: T<n> -> "tid pid start"
SCOPERS_DIR = os.path.join(DIR, "scopers")         # one lock file per running scope pass
DAEMON_LOCK = os.path.join(DIR, ".daemon.lock")   # lifetime flock -> single instance
BLOCKED_SIG = os.path.join(DIR, ".blocked_sig")
CANCEL = os.path.join(DIR, ".cancel")              # plugin drops this to abort a running worker (tid, or empty=all)
LOG         = os.path.join(DIR, "loop.log")
WORKER_TIMEOUT = 900
RETRY_INTERVAL = int(_opt("--retry-interval", "600"))  # rate-limited tasks re-try this
                           # often (cap on the API's resetsAt) so an early clear is picked
                           # up and the task keeps trying instead of sitting blocked
SCOPE_TIMEOUT  = 120        # Haiku scope pass; short -> fall back to exclusive fast (was 240)
MAX_WORKERS = int(_opt("--max-workers", "3"))      # concurrent exec workers
MAX_SCOPERS = int(_opt("--max-scopers", "3"))      # concurrent scope passes
SCOPE_MODEL = _opt("--scope-model", "claude-haiku-4-5-20251001")
# Exec workers default to Sonnet (most UI edits don't need Opus — ~5x cheaper). A task can
# opt up/down by putting a model keyword in its {tags}: {opus} / {sonnet} / {haiku}.
WORKER_MODEL = _opt("--worker-model", "claude-sonnet-4-6")
MODEL_ALIASES = {"opus": "claude-opus-4-8", "sonnet": "claude-sonnet-4-6",
                 "haiku": "claude-haiku-4-5-20251001"}
# Warm-resume a rework into the prior worker's session ONLY if it likely still has a warm
# prompt cache (Anthropic TTL ~5 min). Cold resume would replay the whole transcript as fresh
# input (a loss vs a tight cold start), so we hard-guard on recency: resume = pure win or skip.
RESUME_TTL = int(_opt("--resume-ttl", "240"))
# Where the agent's global config + symlinked helpers live (default ~/.claude). Override
# with $CLAUDE_DIR so the loop adopts cleanly on machines that keep it elsewhere.
CLAUDE_DIR = os.environ.get("CLAUDE_DIR") or os.path.expanduser("~/.claude")
# Trim the per-dispatch context tax the OAuth-safe way (NOT --bare, which forces an API key).
# claudeMdExcludes (passed via --settings, per-launch, so the user's interactive sessions are
# untouched) drops global CLAUDE.md files that are irrelevant/misleading for a sandboxed edit
# worker (e.g. throughput/git rules, a framework doc for the wrong framework, proxy notes). Which
# docs to drop is inherently per-setup, so the DEFAULT is empty — portable, no assumptions about
# what global docs exist. Opt in via $TASKLOOP_EXCLUDE_MD="a.md,b.md" (a literal "$CLAUDE_DIR"
# token in the value is expanded), or per-launch with --exclude-md "p1,p2" ("" disables).
_excl_default = os.environ.get("TASKLOOP_EXCLUDE_MD", "")
EXCLUDE_CLAUDE_MD = [os.path.expanduser(p.strip().replace("$CLAUDE_DIR", CLAUDE_DIR))
                     for p in _opt("--exclude-md", _excl_default).split(",") if p.strip()]
# Workers stay in acceptEdits (they edit files freely) but get an explicit allowlist
# so they can RUN the project's verify/format/lint/test commands — see the typecheck
# errors and fix them — WITHOUT being able to run arbitrary/destructive commands.
# Pipes split into parts, so the read filters (tail/grep/…) are allowlisted too, which
# is why `pnpm check 2>&1 | tail -40` now passes. Everything else still requires
# approval (i.e. blocked in headless) — no rm, git-mutations, curl, arbitrary scripts.
WORKER_ALLOW = [
    "Bash(pnpm:*)", "Bash(npm:*)", "Bash(yarn:*)", "Bash(npx:*)", "Bash(bun:*)",
    "Bash(tsc:*)", "Bash(svelte-check:*)", "Bash(eslint:*)", "Bash(biome:*)",
    "Bash(prettier:*)", "Bash(vitest:*)", "Bash(jest:*)", "Bash(make:*)",
    "Bash(tail:*)", "Bash(head:*)", "Bash(grep:*)", "Bash(rg:*)", "Bash(cat:*)",
    "Bash(sed:*)", "Bash(awk:*)", "Bash(sort:*)", "Bash(uniq:*)", "Bash(wc:*)", "Bash(cut:*)",
]
_worker_settings = {"permissions": {"allow": WORKER_ALLOW}}
if EXCLUDE_CLAUDE_MD:
    _worker_settings["claudeMdExcludes"] = EXCLUDE_CLAUDE_MD
WORKER_SETTINGS = json.dumps(_worker_settings)
POLL = 2
GC_GRACE = 120
APPROVALS = {"gg","good","lgtm","looks good","approved","approve","ok","okay","ship it",
             "shipit","ship","accept","accepted","perfect","nice","👍"}
HEADING = re.compile(r"^###\s+(?P<rest>.*\S)\s*$")
ID_RE   = re.compile(r"\[#(\d+)\]")
TAG_RE  = re.compile(r"\{([^}]*)\}")
FILES_RE = re.compile(r"^\s*files?\s*:\s*(.+)$", re.I | re.M)  # declared claim in task body
HINTS = ("Follow the standing hints: use the project's OWN design tokens, styling, and "
         "conventions — grep the repo to find real token/class names; never invent them or "
         "carry over names from another project. Run the "
         "project's formatter and typecheck (find the commands in package.json scripts / the "
         "repo's CLAUDE.md), reporting only your own files' errors. "
         "CRITICAL: NEVER run git commands that change files or history — no `git checkout`, "
         "`git restore`, `git reset`, `git stash`, `git revert`, no `git show HEAD:… > file`, "
         "no copying/backing up files. The WORKING TREE is the source of truth and holds "
         "uncommitted work your task builds on; do NOT compare against or restore from HEAD. "
         "Just edit the files in place. (`git status`/`git diff` to read is fine.) "
         "ALSO: do NOT start or run the app/dev server (no `npm run start*`/`masq-*`/`dev`/"
         "`serve`/`rsbuild dev`), no backgrounding (`&`), no `sleep` loops, no waiting on logs "
         "— you can't see the browser and the USER does the visual verify. "
         "RUNTIME/VISUAL BUGS you can't confirm headlessly (DOM, events, styling, "
         "selection/caret, anything that only shows in the browser): do NOT guess across "
         "rounds. INSTRUMENT instead — add a single `console.log('[probe]', JSON.stringify({…}))` "
         "at the decision point, then make your result a request: in 'Verify by' tell the user the "
         "EXACT action that triggers it (e.g. \"type ':t' in the composer\") and to paste the "
         "'[probe]' line back as a rework note. Next round, use that data to fix and remove the "
         "probe. (The user is your eyes — a precise probe + their paste beats blind edits.) "
         "Make the edit, typecheck, write the result, and stop.")

# ---- small utils ----------------------------------------------------------
def logline(msg):
    try:
        with open(LOG, "a", encoding="utf-8") as f:
            f.write(f"{datetime.datetime.now():%H:%M:%S}  {msg}\n")
    except Exception:
        pass

def h(s):
    return hashlib.sha1(s.encode("utf-8")).hexdigest()[:12]

def load_state():
    try:
        with open(STATE_F, encoding="utf-8") as f:
            st = json.load(f)
    except Exception:
        st = {"next_id": 1, "tasks": {}, "consumed": {}, "file_index": {}, "accepted": []}
    # consumed is a SET of acted verdict-hashes per id (list in json). Migrate any
    # old single-string values so distinct notes each fire once and accumulate.
    for k, v in list(st.get("consumed", {}).items()):
        if isinstance(v, str):
            st["consumed"][k] = [v]
    return st

def save_state(st):
    if DRY:
        return
    tmp = STATE_F + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(st, f, indent=1)
    os.replace(tmp, STATE_F)

def read(path):
    try:
        with open(path, encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return ""

def norm_path(p):
    """Normalise a claimed path to repo-relative, no leading ./ or absolute prefix."""
    p = p.strip().strip("`'\"").lstrip()
    if p.startswith(ROOT):
        p = os.path.relpath(p, ROOT)
    if p.startswith("./"):
        p = p[2:]
    return p

def split_files(raw):
    return [norm_path(f) for f in re.split(r"[,\n]", raw) if f.strip()]

# ---- parsing --------------------------------------------------------------
def declared_files(body):
    """Optional `files: a.ts, b.ts` line in a task body -> claim list (or None)."""
    m = FILES_RE.search(body or "")
    if not m:
        return None
    files = [f for f in split_files(m.group(1)) if f]
    return files or None

def parse_tasks(text):
    """Return list of blocks: {id|None, title, tags, body, heading_idx}."""
    lines = text.split("\n")
    blocks, i, n = [], 0, len(lines)
    while i < n:
        m = HEADING.match(lines[i])
        if not m:
            i += 1; continue
        start = i; i += 1
        while i < n and not HEADING.match(lines[i]):
            i += 1
        rest = m.group("rest")
        tid = ID_RE.search(rest)
        tag = TAG_RE.search(rest)
        title = ID_RE.sub("", rest)
        title = TAG_RE.sub("", title).strip()
        body = "\n".join(lines[start + 1:i]).strip()
        blocks.append({
            "id": tid.group(1) if tid else None,
            "title": title, "tags": (tag.group(1).strip() if tag else ""),
            "body": body, "heading_idx": start,
        })
    return lines, blocks

def parse_review(text):
    """Verdicts, one per id. Single-line `#NN <verdict>`, OR a fenced multi-line
    block `#NN <<` … `>>` (the plugin writes the fence for multi-line rework notes)."""
    out, lines, i, n = [], text.split("\n"), 0, len(text.split("\n"))
    while i < n:
        m = re.match(r"^\s*#(\d+)\s*(.*)$", lines[i])
        if not m:
            i += 1; continue
        tid, rest = m.group(1), m.group(2).strip()
        if rest == "<<":                      # fenced multi-line
            body, i = [], i + 1
            while i < n and lines[i].strip() != ">>":
                body.append(lines[i]); i += 1
            i += 1                            # consume the closing >>
            v = "\n".join(body).strip()
            if v:
                out.append((tid, v))
        elif rest:
            out.append((tid, rest)); i += 1
        else:
            i += 1
    return out

def classify(verdict):
    v = verdict.strip().lower().rstrip(" .!")
    if v.startswith("?"):
        return "question"
    if v in APPROVALS:
        return "accept"
    return "rework"

# ---- lock layer (one file per running subprocess) -------------------------
def _list_locks(d):
    out = {}
    if not os.path.isdir(d):
        return out
    for fn in os.listdir(d):
        m = re.match(r"^T(\d+)$", fn)
        if not m:
            continue
        try:
            tid, pid, start = open(os.path.join(d, fn)).read().split()
            out[tid] = (int(pid), float(start))
        except Exception:
            pass
    return out

def running_workers():
    return _list_locks(WORKERS_DIR)

def running_scopers():
    return _list_locks(SCOPERS_DIR)

def write_lock(d, tid, pid):
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, f"T{tid}"), "w", encoding="utf-8") as f:
        f.write(f"{tid} {pid} {time.time()}")

def clear_lock(d, tid):
    try:
        os.remove(os.path.join(d, f"T{tid}"))
    except OSError:
        pass

def pid_alive(pid):
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    except Exception:
        return False
    # os.kill(pid, 0) also succeeds for a ZOMBIE — an exited worker this daemon
    # parented but never wait()ed. That would look 'alive' forever and pin the task
    # in 'doing' until the timeout. Reap it if we can, and report a zombie as dead.
    try: os.waitpid(pid, os.WNOHANG)
    except Exception: pass
    try:
        state = subprocess.run(["ps", "-o", "stat=", "-p", str(pid)],
                               capture_output=True, text=True, timeout=5).stdout.strip()
        if state[:1] in ("Z", ""):   # zombie, or already gone
            return False
    except Exception:
        pass
    return True

def kill_pid(pid):
    try:
        os.killpg(os.getpgid(pid), signal.SIGKILL)
    except Exception:
        try: os.kill(pid, signal.SIGKILL)
        except Exception: pass

def held_files(st, running):
    """Union of claimed files across in-flight workers -> {file: holder_tid}, plus the
    tid of any exclusive worker currently running (or None)."""
    locks, excl = {}, None
    for tid in running:
        t = st["tasks"].get(tid)
        if not t:
            continue
        if t.get("exclusive"):
            excl = tid
        for f in (t.get("claim") or []):
            locks.setdefault(f, tid)
    return locks, excl

# ---- context bridging -----------------------------------------------------
def related_ledger(st, files, self_id):
    """Other tasks that touched any of `files`, plus a few most-recent tasks."""
    ids = []
    for fpath in files:
        ids += st["file_index"].get(fpath, [])
    recent = sorted((t for t in st["tasks"]
                     if st["tasks"][t]["status"] in ("verify", "done")),
                    key=lambda t: int(t), reverse=True)[:5]
    seen, out = set(), []
    for t in ids + recent:
        if t == self_id or t in seen or t not in st["tasks"]:
            continue
        seen.add(t)
        ev = st["tasks"][t].get("evidence") or {}
        what = (ev.get("what") or st["tasks"][t]["title"])[:90]
        out.append(f"  #{t} «{st['tasks'][t]['title'][:40]}» — {what}")
        if len(out) >= 6:
            break
    return out

def build_prompt(st, tid):
    t = st["tasks"][tid]
    thread = t.get("thread", [])
    parts = [f"You are a TASK-LOOP worker. Working dir is the repo root. Task id is #{tid}.",
             f"TITLE: {t['title']}"]
    if t["tags"]:
        parts.append(f"TAGS: {{{t['tags']}}} (issue=stub GitLab issue first; mr=own branch+MR).")
    # full thread = accumulated context (spec -> attempt -> feedback -> ...)
    if thread:
        parts.append("\nTASK THREAD (most recent last) — build on this, don't restart from scratch:")
        for e in thread:
            if e["kind"] == "spec":
                parts.append(f"  • SPEC: {e['text']}")
            elif e["kind"] == "feedback":
                parts.append(f"  • REWORK FEEDBACK: {e['text']}")
            elif e["kind"] == "result":
                parts.append(f"  • PRIOR ATTEMPT did: {e.get('what','')}  (files: {', '.join(e.get('files',[]))})")
    # attached screenshots from feedback — the worker MUST open these
    imgs = re.findall(r"\[img:\s*([^\]]+)\]",
                      " ".join(e.get("text", "") for e in thread if e["kind"] == "feedback"))
    if imgs:
        parts.append("\nThe user attached screenshot(s) with their feedback — OPEN and study "
                     "each one before changing anything (they show exactly what they mean):")
        for ip in imgs:
            parts.append(f"  {ip.strip()}")
    # FILE CLAIM — the heart of parallel safety. Other workers run concurrently on
    # disjoint files; staying inside the claim is what keeps you from colliding.
    claim = t.get("claim") or []
    if t.get("exclusive"):
        parts.append("\nFILE SCOPE: this task is running EXCLUSIVELY (no other worker is "
                     "active) because its file set could not be predicted. Edit only the files "
                     "this task genuinely needs; keep the change tightly scoped.")
    elif claim:
        parts.append("\nFILE CLAIM — OTHER WORKERS ARE EDITING THE REPO IN PARALLEL RIGHT NOW. "
                     "You may edit ONLY these files:")
        for f in claim:
            parts.append(f"  {f}")
        parts.append("If you discover you MUST edit a file not in this list, do NOT edit it — "
                     f"instead write .taskloop/T{tid}.blocked.md with "
                     "'**Blocked:** need to also edit <file(s)>' and stop, so I can re-schedule "
                     "you without a conflict. Creating brand-new files is fine.")
    # scout brief from the read-only scope pass — warm-start orientation (advisory)
    brief = t.get("scope_brief")
    if brief:
        parts.append("\nSCOUT NOTES — a fast read-only scoping pass already explored the repo for "
                     "this task. Use them to start warm (skip re-discovering where things are), but "
                     "they're a quick pass and CAN be wrong — verify against the real code before "
                     "trusting any specific line/name:")
        parts.append(brief)
    # touch index = neighboring changes
    flist = claim or (t.get("evidence") or {}).get("files", [])
    ledger = related_ledger(st, flist, tid)
    if ledger:
        parts.append("\nRELATED TASKS that touched nearby files — keep coherent, don't regress them:")
        parts += ledger
    parts.append("\n" + HINTS)
    parts.append(f"\nWhen finished, WRITE .taskloop/T{tid}.md with these fields, each starting "
                 "on its own marker line: '**What I did:** <one sentence>', then '**Verify by:**' "
                 "on its own line followed by a SHORT numbered list (1-3 steps) of the key things to "
                 "CHECK. Assume the user already has the dev server running and the app open — DO NOT "
                 "include setup steps (starting servers, installing, building, navigating from scratch). "
                 "Start at the relevant screen and state only the high-level check per step (the "
                 "observable outcome), NOT granular play-by-play. Then '**Files:** <path:line list>' "
                 "and '**Issue/MR:** <none or refs>'. "
                 f"If you cannot finish cleanly, instead write .taskloop/T{tid}.blocked.md with "
                 "'**Blocked:** <what you need>' — do NOT thrash to the timeout.")
    return "\n".join(parts)

def worker_model(t):
    """Resolve the exec model for a task: a {opus|sonnet|haiku} keyword in its tags wins,
    else the daemon default (Sonnet). Lets cheap edits run cheap and hard ones escalate."""
    tags = (t.get("tags") or "").lower()
    for k in ("opus", "sonnet", "haiku"):
        if re.search(rf"\b{k}\b", tags):
            return MODEL_ALIASES[k]
    return WORKER_MODEL

def build_resume_prompt(st, tid):
    """Minimal prompt for a resumed session — it already holds the full context + prior edits,
    so we send only the new feedback (+ claim reminder + result contract)."""
    t = st["tasks"][tid]
    fbs = [e["text"] for e in t.get("thread", []) if e["kind"] == "feedback"]
    latest = fbs[-1] if fbs else "(address the latest feedback)"
    parts = [f"REWORK on task #{tid} — SAME session: you already have the full task context and "
             "your prior changes in memory. Address ONLY this new feedback:", latest]
    imgs = re.findall(r"\[img:\s*([^\]]+)\]", latest)
    if imgs:
        parts.append("Open and study the attached screenshot(s) first:")
        parts += [f"  {ip.strip()}" for ip in imgs]
    if t.get("claim") and not t.get("exclusive"):
        parts.append("Still edit ONLY your claimed files: " + ", ".join(t["claim"]) +
                     f". If you need another, write .taskloop/T{tid}.blocked.md instead.")
    parts.append(f"When done, OVERWRITE .taskloop/T{tid}.md with the result fields "
                 "(**What I did:** one sentence / **Verify by:** a SHORT numbered list, 1-3 high-level "
                 "checks — assume the dev server is up and the app open, no setup steps, no granular "
                 "play-by-play / **Files:** / **Issue/MR:**), "
                 f"or write .taskloop/T{tid}.blocked.md if blocked.")
    return "\n".join(parts)

def launch_worker(st, tid):
    t = st["tasks"][tid]
    model = worker_model(t)
    is_rework = any(e["kind"] == "feedback" for e in t.get("thread", []))
    # warm-resume only if we have the prior session AND it's recent enough to still be cached
    warm = bool(t.get("session_id")) and (time.time() - t.get("last_active", 0) < RESUME_TTL)
    resume = is_rework and warm
    logf = open(os.path.join(DIR, f"T{tid}.log"), "a", encoding="utf-8")
    mode = f"resume {t['session_id'][:8]}" if resume else f"{model} bare"
    logf.write(f"\n===== {datetime.datetime.now():%H:%M:%S} launch #{tid} ({mode}) =====\n"); logf.flush()
    if resume:
        # model + bare are fixed at session creation; --resume continues with them
        cmd = ["claude", "-p", build_resume_prompt(st, tid), "--resume", t["session_id"],
               "--output-format", "stream-json", "--verbose", "--permission-mode", "acceptEdits"]
    else:
        # NB: NOT --bare — that forces ANTHROPIC_API_KEY auth (OAuth/keychain never read), which
        # would break workers on this OAuth login. Trim the instruction tax via claudeMdExcludes
        # (--settings) instead — OAuth-safe, per-launch.
        cmd = ["claude", "-p", build_prompt(st, tid), "--model", model,
               "--output-format", "stream-json", "--verbose", "--permission-mode", "acceptEdits"]
    if WORKER_SETTINGS:   # both branches: carry the verify-command allowlist + md excludes
        cmd += ["--settings", WORKER_SETTINGS]
    proc = subprocess.Popen(cmd, cwd=ROOT, stdout=logf, stderr=subprocess.STDOUT,
                            start_new_session=True)
    write_lock(WORKERS_DIR, tid, proc.pid)
    t["status"] = "doing"
    t["dispatched_at"] = time.time()
    src = t.get("claim_src", "?")
    n = len((t.get("claim") or []))
    tag = "exclusive" if t.get("exclusive") else f"{n}f/{src}"
    short = "resume" if resume else (model.split("-")[1] if "-" in model else model)
    logline(f"DISPATCH #{tid} «{t['title'][:40]}» [{tag}·{short}]" + (" (rework)" if is_rework else ""))

# ---- scope pass (read-only file prediction) -------------------------------
def launch_scoper(st, tid):
    t = st["tasks"][tid]
    spec = t["title"] + ("\n" + "\n".join(
        e["text"] for e in t.get("thread", []) if e["kind"] in ("spec", "feedback")))
    prompt = ("You are a READ-ONLY scope pass for a parallel task runner. Do NOT edit, create, "
              "or delete ANY file — only read and grep. Your job is twofold: (1) determine the "
              "minimal set of EXISTING repo-relative files this task would need to MODIFY (omit "
              "files you'd only read, and omit brand-new files that don't exist yet) — be precise: "
              "over-claiming serialises the work, under-claiming risks a collision; (2) write a "
              "short SCOUT BRIEF to warm-start the worker who will do the edit.\n\nTASK:\n" + spec +
              "\n\nReply in EXACTLY this shape and nothing else:\n"
              "BRIEF:\n"
              "<up to ~8 bullet lines: where the relevant code lives (file:line / "
              "function / component), the existing pattern or token names to follow, and any "
              "gotcha. Concrete pointers only — no restating the task, no edits.>\n"
              "CLAIM: <comma-separated repo-relative file paths>\n"
              "The CLAIM line MUST be last. If you genuinely cannot predict the files, write "
              "`CLAIM: *` (the task will then run alone) — still give the BRIEF. Nothing after CLAIM.")
    logf = open(os.path.join(DIR, f"T{tid}.scope.log"), "w", encoding="utf-8")
    logf.write(f"===== {datetime.datetime.now():%H:%M:%S} scope #{tid} =====\n"); logf.flush()
    cmd = ["claude", "-p", prompt, "--model", SCOPE_MODEL, "--permission-mode", "plan"]
    if WORKER_SETTINGS:
        cmd += ["--settings", WORKER_SETTINGS]
    proc = subprocess.Popen(cmd, cwd=ROOT, stdout=logf, stderr=subprocess.STDOUT,
                            start_new_session=True)
    write_lock(SCOPERS_DIR, tid, proc.pid)
    logline(f"SCOPE #{tid} «{t['title'][:40]}»")

def parse_scope(tid):
    """Read the scope log -> (claim_list_or_None, brief_text). claim None = exclusive."""
    txt = read(os.path.join(DIR, f"T{tid}.scope.log"))
    claim = None
    cms = list(re.finditer(r"^\s*CLAIM:\s*(.+?)\s*$", txt, re.M | re.I))
    if cms:
        raw = cms[-1].group(1).strip()
        if raw and raw != "*":
            files = [f for f in split_files(raw) if f and f != "*"]
            claim = files or None
    # brief = text between the BRIEF: marker and the final CLAIM line
    brief = ""
    bm = re.search(r"^\s*BRIEF:\s*$", txt, re.M | re.I) or re.search(r"^\s*BRIEF:\s*", txt, re.M | re.I)
    if bm:
        seg = txt[bm.end():]
        if cms:
            tail = re.search(r"^\s*CLAIM:.*$", seg, re.M | re.I)
            if tail:
                seg = seg[:tail.start()]
        brief = seg.strip()[:1200]
    return claim, brief

def capture_session(tid, t):
    """Best-effort: pull session_id out of the stream-json log for later resume."""
    try:
        with open(os.path.join(DIR, f"T{tid}.log"), encoding="utf-8") as f:
            for ln in f:
                m = re.search(r'"session_id"\s*:\s*"([^"]+)"', ln)
                if m:
                    t["session_id"] = m.group(1)
    except Exception:
        pass

def parse_result(path):
    txt = read(path)
    def grab(label):
        m = re.search(rf"\*\*{label}:\*\*\s*(.*)", txt)
        return m.group(1).strip() if m else ""
    # `Verify by` is a multi-line block of steps — capture everything up to the
    # next known field marker so the numbered steps survive intact.
    def grab_block(label):
        m = re.search(rf"\*\*{re.escape(label)}:\*\*\s*(.*?)"
                      r"(?=\n\*\*(?:What I did|Verify by|Files|Issue/MR):\*\*|\Z)", txt, re.S)
        return m.group(1).strip() if m else ""
    files = [f.strip() for f in grab("Files").split(",") if f.strip()]
    files = [norm_path(f.split(":")[0]) for f in files]  # strip :line, normalise
    return {"what": grab("What I did"), "verify": grab_block("Verify by"),
            "files": files, "issue": grab("Issue/MR")}

# Terminal failures a worker can hit without writing a result — matched against the
# tail of its log so the task is parked promptly (with a real reason) instead of
# sitting in 'doing' until the timeout. Patterns are specific enough not to fire on
# ordinary assistant prose (structured CLI/API error markers + distinctive strings).
FAIL_SIGNATURES = [
    (re.compile(r'"subtype"\s*:\s*"error_max_turns"'),         "hit max turns without finishing"),
    (re.compile(r'"subtype"\s*:\s*"error_during_execution"'),  "errored during execution"),
    (re.compile(r'Prompt is too long|context_length_exceeded|exceeds the maximum.*tokens', re.I),
                                                               "ran out of context (prompt too long)"),
    # ONLY the final result event — a tool_result with is_error:true is a single
    # failed/denied tool call the worker normally recovers from, NOT a task failure.
    (re.compile(r'\{"type"\s*:\s*"result"[^\n]*"is_error"\s*:\s*true'), "worker reported an error"),
]

# A rate / usage limit REJECTION is recoverable (auto-retry once it clears). Match
# ONLY a real rejection: the API returns 429, or the rate_limit_event flips to
# "status":"rejected". NB the rate_limit_event ALSO rides on every SUCCESSFUL
# response as "status":"allowed" (with rateLimitType / member_zero_credit_limit as
# informational overage notes) — matching those would falsely kill healthy workers.
RATELIMIT_RE = re.compile(r'"api_error_status"\s*:\s*429'
                          r'|"status"\s*:\s*"rejected"'
                          r'|hit your session limit', re.I)
RESETS_RE = re.compile(r'"resetsAt"\s*:\s*(\d+)')

def worker_log_failure(tid):
    """Scan the CURRENT run's log for a terminal failure. Returns (reason, retry_at):
    retry_at is an epoch for a recoverable rate/usage limit (auto-retry then), None
    for failures that need you; reason is None if the run looks healthy. The log is
    append-only across (re)dispatches, so we cut to everything after the last
    'launch #<tid>' marker — otherwise a prior run's error would falsely fail a
    freshly re-dispatched worker."""
    path = os.path.join(DIR, f"T{tid}.log")
    try:
        with open(path, "rb") as f:
            f.seek(0, 2); size = f.tell()
            f.seek(max(0, size - 65536))
            tail = f.read().decode("utf-8", "replace")
    except Exception:
        return (None, None)
    idx = tail.rfind(f"launch #{tid} ")   # start of the most recent run, if in window
    if idx != -1:
        tail = tail[idx:]
    if RATELIMIT_RE.search(tail):
        m = RESETS_RE.search(tail)
        retry_at = float(m.group(1)) if m else time.time() + 1800   # fallback: 30 min
        return ("rate/usage limit", retry_at)
    for rx, reason in FAIL_SIGNATURES:
        if rx.search(tail):
            return (reason, None)
    return (None, None)

# ---- the tick -------------------------------------------------------------
def tick():
    if not os.path.exists(TASKS):
        return
    st = load_state()
    acted = []

    # --- A0. user-requested cancel: kill a running worker and PARK its task so the loop
    # moves on (parked task won't auto-requeue; add a REVIEW note to resume). The plugin
    # drops `.cancel` containing the tid, or empty = cancel ALL running exec workers. ---
    if os.path.exists(CANCEL):
        want = read(CANCEL).strip()
        for tid, (pid, _) in running_workers().items():
            if want and want != tid:
                continue
            kill_pid(pid)
            t = st["tasks"].get(tid)
            if t:
                t["status"] = "blocked"
                t["blocked"] = f"cancelled by you — add a REVIEW note (#{tid} <what next>) to resume"
            clear_lock(WORKERS_DIR, tid)
            acted.append(f"CANCELLED:#{tid}")
        if not DRY:
            try: os.remove(CANCEL)
            except OSError: pass

    # --- A. reap exec workers (result / blocked / died / timeout) -> release file locks ---
    running = running_workers()
    locks_now, _ = held_files(st, running)
    for tid, (pid, start) in running.items():
        res = os.path.join(DIR, f"T{tid}.md")
        blk = os.path.join(DIR, f"T{tid}.blocked.md")
        t = st["tasks"].get(tid)
        if os.path.exists(res):
            ev = parse_result(res)
            if t:
                t["status"] = "verify"; t["evidence"] = ev
                t.setdefault("thread", []).append({"kind": "result", **ev})
                for fp in ev["files"]:
                    st["file_index"].setdefault(fp, [])
                    if tid not in st["file_index"][fp]:
                        st["file_index"][fp].append(tid)
                capture_session(tid, t)
                t["last_active"] = time.time()  # for the warm-resume freshness guard
                # collision backstop: did it edit a file ANOTHER live worker holds, or
                # a file outside its own claim?
                claim = set(t.get("claim") or [])
                stray = [f for f in ev["files"]
                         if (f in locks_now and locks_now[f] != tid)
                         or (claim and f not in claim and not t.get("exclusive"))]
                if stray:
                    t["conflict"] = ("edited outside claim / shared with a parallel worker: "
                                     + ", ".join(stray) + " — re-verify carefully")
                    acted.append(f"CONFLICT:#{tid}")
                else:
                    t.pop("conflict", None)
            if not DRY: os.remove(res)
            clear_lock(WORKERS_DIR, tid); acted.append(f"VERIFY:#{tid}")
        elif os.path.exists(blk):
            reason = read(blk).replace("**Blocked:**", "").strip()
            if t: t["status"] = "blocked"; t["blocked"] = reason
            if not DRY: os.remove(blk)
            clear_lock(WORKERS_DIR, tid); acted.append(f"BLOCKED:#{tid}")
        else:
            reason, retry_at = worker_log_failure(tid)
            if reason and retry_at is not None:
                # recoverable rate/usage limit — park as rate_limited and auto-retry
                # once the window resets (see A3). No babysitting required.
                kill_pid(pid)
                # Don't wait the whole window — retry every RETRY_INTERVAL so an early
                # clear is caught and the task keeps trying instead of sitting blocked.
                retry_at = min(retry_at, time.time() + RETRY_INTERVAL)
                if t:
                    t["status"] = "rate_limited"; t["retry_at"] = retry_at; t.pop("blocked", None)
                clear_lock(WORKERS_DIR, tid)
                acted.append(f"RATELIMIT:#{tid}(retry {datetime.datetime.fromtimestamp(retry_at):%H:%M})")
            elif reason:
                # terminal failure (max turns, exec error, context overflow): park it
                # now with the real reason rather than waiting for the timeout — before
                # pid_alive so a hung/zombie worker is caught too.
                kill_pid(pid)
                if t: t["status"] = "blocked"; t["blocked"] = reason
                clear_lock(WORKERS_DIR, tid); acted.append(f"FAILED:#{tid}({reason})")
            elif not pid_alive(pid):
                if t: t["status"] = "blocked"; t["blocked"] = "worker exited without a result"
                clear_lock(WORKERS_DIR, tid); acted.append(f"DIED:#{tid}")
            elif time.time() - start > WORKER_TIMEOUT:
                kill_pid(pid)
                if t: t["status"] = "blocked"; t["blocked"] = f"worker timed out after {WORKER_TIMEOUT}s"
                clear_lock(WORKERS_DIR, tid); acted.append(f"TIMEOUT:#{tid}")

    # --- A1. reap scope passes -> record claim (or exclusive fallback) ---
    for tid, (pid, start) in running_scopers().items():
        t = st["tasks"].get(tid)
        if not pid_alive(pid):
            claim, brief = parse_scope(tid)
            if t:
                if brief:
                    t["scope_brief"] = brief
                if claim:
                    t["claim"] = claim; t["claim_src"] = "scoped"; t.pop("exclusive", None)
                    acted.append(f"SCOPED:#{tid}({len(claim)}f{'+brief' if brief else ''})")
                else:
                    t["exclusive"] = True; t["claim"] = []; t["claim_src"] = "exclusive"
                    acted.append(f"SCOPED:#{tid}(exclusive{'+brief' if brief else ''})")
            clear_lock(SCOPERS_DIR, tid)
        elif time.time() - start > SCOPE_TIMEOUT:
            kill_pid(pid)
            if t:
                t["exclusive"] = True; t["claim"] = []; t["claim_src"] = "exclusive"
            clear_lock(SCOPERS_DIR, tid); acted.append(f"SCOPE-TIMEOUT:#{tid}")

    # --- A2. heal orphaned 'doing' tasks: worker killed / daemon restarted mid-run left
    # the task 'doing' with no live lock. Requeue as 'rework' (thread holds the context). ---
    live = set(running_workers().keys())
    for _tid, _t in st["tasks"].items():
        if _t.get("status") == "doing" and _tid not in live:
            _t["status"] = "rework"
            acted.append(f"REQUEUE-ORPHAN:#{_tid}")

    # --- A3. auto-retry rate-limited tasks once their reset window has passed. The
    # normal dispatch (E) then picks them back up; if still limited, the reap re-parks
    # them as rate_limited with the new resetsAt — self-healing, no user action. ---
    for _tid, _t in st["tasks"].items():
        if _t.get("status") == "rate_limited" and time.time() >= _t.get("retry_at", 0):
            _t["status"] = ("rework" if any(e.get("kind") == "feedback"
                                            for e in _t.get("thread", [])) else "todo")
            _t.pop("retry_at", None); _t.pop("blocked", None)
            acted.append(f"RATELIMIT-RETRY:#{_tid}")

    # --- B. parse TASKS.md; register new blocks; capture declared claim; fallback id-stamp ---
    lines, blocks = parse_tasks(read(TASKS))
    present_ids = set()
    pending = st.get("_pending", {})
    new_pending = {}
    stamp = []  # (heading_idx, id, block) fallback stamps for hand-added id-less blocks
    for b in blocks:
        decl = declared_files(b["body"])
        if b["id"]:
            present_ids.add(b["id"])
            t = st["tasks"].get(b["id"])
            if not t:
                st["tasks"][b["id"]] = {
                    "title": b["title"], "tags": b["tags"], "status": "todo",
                    "body_hash": h(b["body"]),
                    "thread": [{"kind": "spec",
                                "text": (b["title"] + ("\n" + b["body"] if b["body"] else ""))}]}
                t = st["tasks"][b["id"]]
                if decl:
                    t["claim"] = decl; t["claim_src"] = "declared"
            else:
                t["title"], t["tags"] = b["title"], b["tags"]
                # a declared `files:` line is AUTHORITATIVE: it fills an unknown claim AND
                # overrides a wrong scoped/exclusive claim (e.g. to unblock a task that needed
                # files outside its claim, or to force a parallel claim onto an exclusive task).
                # Never change a claim while that task's worker is running.
                if decl and decl != t.get("claim") and b["id"] not in live:
                    t["claim"] = decl; t["claim_src"] = "declared"; t.pop("exclusive", None)
                    acted.append(f"CLAIM-SET:#{b['id']}({len(decl)}f)")
            continue
        # id-less: stabilise across one tick, then stamp (fallback for hand-added blocks)
        key = h(f"{b['heading_idx']}|{b['title']}|{b['body']}")
        if key in pending:
            nid = str(st["next_id"]); st["next_id"] += 1
            stamp.append((b["heading_idx"], nid, b))
        else:
            new_pending[key] = True
    st["_pending"] = new_pending

    if stamp and not DRY:
        # one atomic rewrite of TASKS.md, stability-guarded (never clobber a concurrent edit)
        cur = read(TASKS)
        if cur == "\n".join(lines) or cur.split("\n") == lines:
            for idx, nid, b in stamp:
                lines[idx] = lines[idx].rstrip() + f"  [#{nid}]"
                st["tasks"][nid] = {
                    "title": b["title"], "tags": b["tags"], "status": "todo",
                    "body_hash": h(b["body"]),
                    "thread": [{"kind": "spec",
                                "text": (b["title"] + ("\n" + b["body"] if b["body"] else ""))}]}
                decl = declared_files(b["body"])
                if decl:
                    st["tasks"][nid]["claim"] = decl; st["tasks"][nid]["claim_src"] = "declared"
                present_ids.add(nid)
                acted.append(f"ID:#{nid}")
            tmp = TASKS + ".tmp"
            with open(tmp, "w", encoding="utf-8") as f: f.write("\n".join(lines))
            os.replace(tmp, TASKS)

    # --- C. read REVIEW.md verdicts; act on each UNSEEN one ---
    # consumed[tid] is a SET of acted verdict-hashes (each distinct note fires once and
    # they ACCUMULATE). A task whose worker is in-flight is left alone until it finishes.
    running_now = set(running_workers().keys())
    for tid, verdict in parse_review(read(REVIEW)):
        if tid not in st["tasks"] or tid in running_now:
            continue
        seen = st["consumed"].setdefault(tid, [])
        vh = h(verdict)
        if vh in seen:
            continue
        kind = classify(verdict)
        t = st["tasks"][tid]
        if kind == "accept":
            if t["status"] not in ("verify", "blocked"):
                continue  # not acceptable yet — leave UNseen so it acts once verifiable
            t["status"] = "done"
            st["accepted"] = ([tid] + [x for x in st.get("accepted", []) if x != tid])[:20]
            acted.append(f"ACCEPT:#{tid}")
        elif kind == "rework":
            t.setdefault("thread", []).append({"kind": "feedback", "text": verdict})
            t["status"] = "rework"
            acted.append(f"REWORK-QUEUED:#{tid}")
        elif kind == "question":
            t["question"] = verdict.lstrip("? ").strip()
        seen.append(vh)

    # --- D. dispatch SCOPE passes for runnable tasks whose claim is still unknown ---
    if not DRY:
        scoping = set(running_scopers().keys())
        ns = len(scoping)
        for tid in sorted(st["tasks"], key=lambda x: int(x)):
            if ns >= MAX_SCOPERS:
                break
            t = st["tasks"][tid]
            if t["status"] not in ("todo", "rework"):
                continue
            if t.get("claim") is not None or t.get("exclusive") or tid in scoping:
                continue
            launch_scoper(st, tid); scoping.add(tid); ns += 1

    # --- E. dispatch EXEC workers, file-lock scheduled, up to MAX_WORKERS ---
    if not DRY:
        running = running_workers()
        locks, excl = held_files(st, running)
        n = len(running)
        cands = [t for t in sorted(st["tasks"], key=lambda x: int(x))
                 if st["tasks"][t]["status"] == "rework"] + \
                [t for t in sorted(st["tasks"], key=lambda x: int(x))
                 if st["tasks"][t]["status"] == "todo"]
        for tid in cands:
            if n >= MAX_WORKERS:
                break
            t = st["tasks"][tid]
            if t.get("claim") is None and not t.get("exclusive"):
                continue  # awaiting a scope pass
            if t.get("exclusive"):
                # run alone: needs an empty field. Head-of-line block so it can't starve.
                if n == 0 and excl is None:
                    launch_worker(st, tid); excl = tid; n += 1
                break
            if excl is not None:
                break  # an exclusive worker is running — hold all launches
            cl = t.get("claim") or []
            if any(f in locks for f in cl):
                continue  # a claimed file is busy — wait
            launch_worker(st, tid)
            for f in cl:
                locks.setdefault(f, tid)
            n += 1

    # --- F. render STATUS.md (daemon-owned) ---
    if not DRY:
        render_status(st)

    # --- G. asset GC (by present ids) ---
    if os.path.isdir(ASSETS):
        for a in glob.glob(os.path.join(ASSETS, "*")):
            am = re.match(r"^T(\d+)", os.path.basename(a))
            try: fresh = (time.time() - os.path.getmtime(a)) < GC_GRACE
            except OSError: fresh = False
            if am and not fresh and am.group(1) not in present_ids:
                if not DRY:
                    try: os.remove(a)
                    except OSError: pass
                acted.append(f"GC:{os.path.basename(a)}")

    save_state(st)
    if acted and not DRY:
        logline("  ".join(acted))

    # --- H. blocked-wake (edge-triggered to stdout for the nvim notify watcher) ---
    blocked = sorted((tid for tid in st["tasks"] if st["tasks"][tid]["status"] == "blocked"),
                     key=lambda x: int(x))
    sig = "|".join(blocked)
    last = read(BLOCKED_SIG).strip()
    if not DRY and sig != last:
        with open(BLOCKED_SIG, "w", encoding="utf-8") as f: f.write(sig)
        if sig:
            print(f"BLOCKED — needs you: {sig}", flush=True)
    if DRY:
        print("DRY:", acted or "none", "| blocked:", sig or "none")

def render_status(st):
    now = datetime.datetime.now()
    out = ["# Task Loop — STATUS (read-only; I regenerate this. Edit TASKS.md / REVIEW.md instead)",
           f"updated {now:%H:%M:%S}  ·  {MAX_WORKERS} workers", ""]
    T = st["tasks"]
    running = running_workers()
    scoping = running_scopers()
    locks, excl = held_files(st, running)

    verify = [t for t in sorted(T, key=lambda x: int(x)) if T[t]["status"] == "verify"]

    def emit_verify_block():
        for tid in verify:
            t = T[tid]; ev = t.get("evidence") or {}
            out.append(f"### #{tid} «{t['title']}»  {{{t['tags'] or 'none'}}}")
            if ev.get("what"):   out.append(f"what:    {ev['what']}")
            if ev.get("verify"):
                vlines = [l.rstrip() for l in str(ev["verify"]).splitlines() if l.strip()]
                if len(vlines) <= 1:
                    out.append(f"verify:  {vlines[0].strip() if vlines else ''}")
                else:
                    out.append("verify — copy/run each step:")
                    out.extend(f"  {l.strip()}" for l in vlines)
            if ev.get("files"):  out.append(f"files:   {', '.join(ev['files'])}")
            if t.get("conflict"): out.append(f"⚠ conflict: {t['conflict']}")
            nfb = sum(1 for e in t.get("thread", []) if e["kind"] == "feedback")
            if nfb: out.append(f"thread:  {nfb} rework round(s)")
            rel = related_ledger(st, ev.get("files", []), tid)
            if rel: out.append("related: " + ", ".join(re.findall(r"#\d+", " ".join(rel))))
            if t.get("question"): out.append(f"question: {t['question']}  (answer in chat)")
            out.append("")

    # ✅ Verify — pinned to the TOP when anything is waiting, since these are the
    # tasks that need YOUR call (accept / rework). Loud banner so it can't be missed.
    if verify:
        bar = "━" * 64
        out += [bar,
                f"## ✅ VERIFY — {len(verify)} waiting on YOU   ·   accept: #NN gg   ·   rework: #NN <note>",
                bar]
        emit_verify_block()
        out.append("")

    # 🔧 Doing (parallel)
    doing = [t for t in sorted(T, key=lambda x: int(x)) if T[t]["status"] == "doing"]
    out.append(f"## 🔧 Doing ({len(doing)}/{MAX_WORKERS})")
    if not doing: out.append("- (idle)")
    for tid in doing:
        el = int(now.timestamp() - T[tid].get("dispatched_at", now.timestamp()))
        cl = T[tid].get("claim") or []
        scope = "exclusive" if T[tid].get("exclusive") else (f"{len(cl)} file(s)" if cl else "?")
        out.append(f"- #{tid} «{T[tid]['title']}» — running {el//60}:{el%60:02d} · {scope}"
                   f"   (tail: .taskloop/T{tid}.log)")

    # 🧭 Scoping
    if scoping:
        out += ["", "## 🧭 Scoping (predicting files)"]
        for tid in sorted(scoping, key=lambda x: int(x)):
            out.append(f"- #{tid} «{T[tid]['title'] if tid in T else '?'}»")

    # ⏳ Queued — todo/rework not yet dispatched, with the reason
    queued = [t for t in sorted(T, key=lambda x: int(x))
              if T[t]["status"] in ("todo", "rework") and t not in running and t not in scoping]
    if queued:
        out += ["", "## ⏳ Queued"]
        for tid in queued:
            t = T[tid]
            if t.get("claim") is None and not t.get("exclusive"):
                reason = "awaiting scope"
            elif t.get("exclusive"):
                reason = "exclusive — waits for all workers idle" if running else "ready (exclusive)"
            elif excl is not None:
                reason = f"#{excl} running exclusively"
            else:
                hit = next((f for f in (t.get("claim") or []) if f in locks), None)
                reason = f"waiting on {hit} (held by #{locks[hit]})" if hit else "ready"
            flag = "rework" if t["status"] == "rework" else "todo"
            out.append(f"- #{tid} «{t['title']}» [{flag}] — {reason}")

    # ✅ Verify — quiet placeholder in its usual spot when nothing's waiting; the
    # prominent top banner above only renders when something actually needs you.
    if not verify:
        out += ["", "## ✅ Verify — (nothing waiting)   →  accept: #NN gg · rework: #NN <note>"]

    # ⏳ Rate-limited — auto-retried once the window resets; no action needed.
    rl = [t for t in sorted(T, key=lambda x: int(x)) if T[t].get("status") == "rate_limited"]
    if rl:
        out += ["", "## ⏳ Rate-limited (auto-retry — no action needed)"]
        for tid in rl:
            ra = T[tid].get("retry_at", 0)
            when = datetime.datetime.fromtimestamp(ra).strftime("%H:%M") if ra else "?"
            out.append(f"- #{tid} «{T[tid]['title']}» — retry at {when}")

    # ⛔ Blocked
    blocked = [t for t in sorted(T, key=lambda x: int(x)) if T[t]["status"] == "blocked"]
    out += ["", "## ⛔ Blocked"]
    if not blocked: out.append("- (none)")
    for tid in blocked:
        out.append(f"- #{tid} «{T[tid]['title']}» — {T[tid].get('blocked','?')}")

    if st.get("accepted"):
        out += ["", "## ✓ recently accepted", " ".join(f"#{x}" for x in st['accepted'])]
    tmp = STATUS + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f: f.write("\n".join(out) + "\n")
    os.replace(tmp, STATUS)

def run_forever():
    os.makedirs(DIR, exist_ok=True)
    fh = open(DAEMON_LOCK, "w")
    try:
        fcntl.flock(fh, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        sys.exit(0)  # another instance holds the lock — expected backstop
    fh.write(str(os.getpid())); fh.flush()
    logline(f"DAEMON2 START (pid {os.getpid()}) tasks={TASKS} max_workers={MAX_WORKERS}")
    try:
        while True:
            try: tick()
            except Exception:
                logline("TICK ERROR: " + traceback.format_exc().replace("\n", " | "))
            time.sleep(POLL)
    finally:
        logline(f"DAEMON2 STOP (pid {os.getpid()})")

if __name__ == "__main__":
    if DRY:
        os.makedirs(DIR, exist_ok=True); tick()
    else:
        run_forever()
