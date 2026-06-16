# TASK-LOOP v2 — single-writer files + nvim front-end

The v2 protocol fixes the v1 pain: in v1 the daemon was the *sole writer* of one
`TASKS.md` that the user **also** typed into (adding tasks, feedback) — so the daemon
constantly rewrote the file under the user's cursor, causing reload churn and lost
edits. v2 guarantees **every file has exactly one writer**, joined by a task id, and
puts an nvim plugin (`taskloop.nvim`) on top so the user never types the grammar by
hand and can tail any running job from the editor.

> `$ROOT` = repo root (`git rev-parse --show-toplevel`). v2 state lives in `.taskloop/`.

## Files & ownership (the whole point)

| File | Writer | Reader | Contents |
|---|---|---|---|
| `TASKS.md` | **you** (via plugin) | daemon reads | your task list — `### <title> {tags}  [#NN]` blocks + body |
| `STATUS.md` | **daemon** (regenerated each tick) | you read | live status + evidence per id, rendered |
| `REVIEW.md` | **you** (via plugin) | daemon reads | your verdicts: one line per id — `#NN gg` / `#NN <rework note>` / `#NN ?<question>` |

- The daemon **never** writes `TASKS.md` or `REVIEW.md`. Its *only* potential write to
  `TASKS.md` is a fallback id-stamp for a block a human added by hand without the plugin
  (append ` [#NN]` to the heading, once, only when the block has been unchanged for a
  full tick). In the normal plugin flow the **plugin** assigns the id at creation, so the
  daemon writes `TASKS.md` zero times.
- The user **never** writes `STATUS.md` (read-only mirror — keep it in a split).
- Because no file has two writers, the editor never reloads under you. That's the fix.

## Identity & lifecycle

- **Identity = the `[#NN]` id.** Stable across reworks. The id is the join key between all
  three files and the daemon's state.
- **Add** a `### title {tags}` block to `TASKS.md` → daemon dispatches a worker.
- **Rework**: `#NN <note>` in `REVIEW.md` → daemon appends the note to the task's thread
  and re-dispatches, primed with the full history + related-task context.
- **Accept**: `#NN gg` (or ok/lgtm/👍/ship) in `REVIEW.md` → daemon marks it done. The
  plugin then removes the block from `TASKS.md` for you (user-side write).
- **Question**: `#NN ?<text>` → surfaced in `STATUS.md`; answered in chat, not by a worker.

## Context bridging (the iteration win)

Each task carries a **thread** in daemon state: `spec → attempt → feedback → attempt → …`.
Every (re)dispatch builds the worker prompt from the *whole thread*, not just the latest
note — so iterating on a task is warm, not a cold re-read. Additionally a **file→task
touch-index** is kept: when (re)dispatching task X the worker is handed a short ledger of
other tasks that touched the same files ("#27 made the composite editor a popover; #29
restyled these buttons") so neighboring changes stay coherent. (Optional later upgrade:
resume the prior worker's `claude -p` session by captured `session_id` for true memory.)

## STATUS.md shape (daemon-rendered)

```
# Task Loop — STATUS (read-only; I regenerate this. Edit TASKS.md / REVIEW.md instead)
updated <ts>  ·  3 workers

## 🔧 Doing (2/3)
- #30 «metadata cog hover» — running 1:23 · 2 file(s)   (tail: .taskloop/T30.log)
- #32 «restyle banner» — running 0:11 · 1 file(s)   (tail: .taskloop/T32.log)

## 🧭 Scoping (predicting files)
- #33 «search empty state»

## ⏳ Queued
- #31 «param field popover» [todo] — waiting on src/…/ParamField.svelte (held by #30)
- #34 «migration sweep» [todo] — exclusive — waits for all workers idle

## ✅ Verify   →  in REVIEW.md:  #30 gg  (accept) ·  #30 <note>  (rework)
### #30 «metadata cog hover»  {none}
what:    <one line>
verify:  <exact check>
files:   src/.../ParamField.svelte
thread:  attempt 2 · 1 prior rework
related: #27, #29 also touched ParamField.svelte

## ⛔ Blocked
- #25 «allowed integrations» — worker timed out

## ✓ recently accepted
#23 #24 #18
```

## Execution — parallel, file-lock scheduled (v2.1)

Workers run **concurrently up to `MAX_WORKERS` (default 3)**, scheduled so two workers
never edit the same file at once. The single-writer-to-the-source-tree guarantee of v1 is
preserved per-file (not per-tree) by a **file-claim** model:

- Each task carries a `claim` = the repo-relative files it will edit. Claims come from, in
  order: (1) a declared `files: a.ts, b.ts` line in the task body — free and exact; (2) a
  fast **read-only scope pass** (`claude -p --permission-mode plan`, Haiku) that greps the
  repo and ends its reply with `CLAIM: <paths>`; (3) **exclusive fallback** — if neither
  yields a claim (or scope says `CLAIM: *`), the task runs ALONE (serial-equivalent).
- A task dispatches only when its claim is **disjoint from every in-flight worker's claim**.
  A conflicting task waits — STATUS.md shows the blocking file + holder (`waiting on
  src/foo.svelte (held by #1)`). Exclusive (unknown-claim) tasks **head-of-line block** so
  they can't starve behind a stream of parallel tasks.
- Enforcement is **soft** (the worker prompt lists its claim and says "edit ONLY these; if
  you must touch another, write `.blocked.md` to re-scope") plus a **collision backstop**:
  if a finished worker's reported `files:` include a path another live worker held — or a
  path outside its own claim — the task is flagged `⚠ conflict` in STATUS for careful
  re-verify.
- **Scout brief (warm-start).** The scope pass already greps/reads the repo to predict the
  files, so it also emits a short `BRIEF:` block (where the code lives, the pattern/tokens to
  follow, gotchas) above its `CLAIM:` line. That brief is stored on the task and injected
  into the exec worker's prompt as advisory `SCOUT NOTES` — the worker starts oriented
  instead of re-discovering the lay of the land. Marked verify-before-trust (it's a quick
  Haiku pass). Only scoped tasks get a brief; declared-`files:` tasks skip the scope pass
  entirely, so they trade the brief for zero scope cost.

Lock layout: one lock file per running subprocess under `.taskloop/workers/T<n>` (exec) and
`.taskloop/scopers/T<n>` (scope), each `"tid pid start"`. Single-instance via a lifetime
`flock`, worker timeout → blocked (scope timeout 240s → exclusive fallback), orphaned
`doing` tasks (killed worker / daemon restart) are healed to `rework`, asset GC by present
ids, blocked-wake printed edge-triggered to stdout (for the nvim notify watcher). Exec
workers run `claude -p … --model <m> --output-format stream-json --verbose
--permission-mode acceptEdits`, stdout → `.taskloop/T<n>.log`; completion is detected by the
worker writing `.taskloop/T<n>.md` (result) or `.taskloop/T<n>.blocked.md`.

**Cost controls.**
- **Model tier:** exec workers default to **Sonnet** (most UI edits don't need Opus, ~5×
  cheaper); a task escalates/downgrades with a model keyword in its `{tags}` — `{opus}`,
  `{sonnet}`, `{haiku}`. Scope passes run Haiku, 120s timeout (fast fall-back to exclusive).
- **Context trim:** workers/scopers launch with `--settings '{"claudeMdExcludes":[…]}'` to
  drop the global CLAUDE.md files irrelevant/misleading to a sandboxed edit worker
  (throughput/glab rules, the React SPA doc, rtk notes) — ~5k tok/dispatch. KEPT: TCN-CSS
  vars, project CLAUDE.md, auto-memory (real repo gotchas). **NOT `--bare`** — that flag
  forces `ANTHROPIC_API_KEY` auth (OAuth/keychain never read) and breaks workers on an OAuth
  login; `claudeMdExcludes` via `--settings` is OAuth-safe and per-launch (interactive
  sessions untouched).
- **Warm-resume on rework:** if a rework re-dispatches within `RESUME_TTL` (240s) of the prior
  attempt, the worker `--resume`s that session (transcript = cache-read) instead of a cold
  restart. Hard-guarded on recency because a *cold* resume would replay the whole transcript
  as fresh input (a loss) — so it's pure-win-when-warm, else a normal fresh start. Mostly
  fires on rapid back-to-back reworks; human-review latency usually exceeds the cache TTL.
- **Cheapest path:** declaring `files:` skips the scope pass entirely.
- Tunables: `--max-workers N`, `--max-scopers N`, `--scope-model <id>`, `--worker-model <id>`,
  `--resume-ttl <s>`, `--exclude-md "p1,p2"` (empty disables the trim).

## State file — `.taskloop/state.json`

```
{ "next_id": 31,
  "tasks": { "30": { "title","tags","status","body_hash","thread":[…],
                     "claim":["src/…/ParamField.svelte"], "claim_src":"declared|scoped|exclusive",
                     "exclusive": false, "conflict":"…", "scope_brief":"<scout notes>",
                     "evidence":{what,verify,files[]}, "session_id", "blocked" } },
  "consumed": { "30": ["<hashes of acted REVIEW verdicts>"] },
  "file_index": { "src/…/ParamField.svelte": ["27","29","30"] },
  "accepted": ["23","24","18"] }
```
`claim` is the scheduling key (null until known → triggers a scope pass); `exclusive` true
means run-alone; `claim_src` records how the claim was derived; `conflict` is the backstop
flag rendered in STATUS.

## nvim front-end — `taskloop.nvim` (prefix = hyper, `<C-A-`)

- `<C-A-t>` Tasks picker (telescope): every task + live status; `<CR>` tail · `<C-f>` feedback · `<C-a>` accept
- `<C-A-n>` new task (scratch buffer → appends a `### title [#NN]` block; plugin assigns the id)
- `<C-A-f>` feedback/rework on task under cursor (writes `#NN <note>` to REVIEW.md)
- `<C-A-a>` accept under cursor (writes `#NN gg`; removes the block from TASKS.md)
- `<C-A-l>` tail that job's `.taskloop/T<n>.log` in a split (renders stream-json readably)
- background: `vim.uv` watch on `.taskloop/loop.log` → `vim.notify` on ⛔ blocked; `STATUS.md` autoreloads
- (h/j/k/l avoided — Karabiner remaps hyper+hjkl to arrows)

## Coexistence & cutover

v2 uses `.taskloop/` + `STATUS.md`/`REVIEW.md`, distinct from v1's `.task-results/` board
in `TASKS.md`, so it can be developed/tested (point it at a scratch task file via
`--tasks`) while v1 keeps running. Cutover: drain v1, `pkill task-loop-daemon.py`, convert
`TASKS.md` to the flat format, launch v2, swap the SessionStart hook to the v2 ensure
script. The hook + perms remain user-owned.
