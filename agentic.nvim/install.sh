#!/usr/bin/env bash
# agentic.nvim installer — symlink the daemon + helper scripts into your agent dir,
# check dependencies, and print the SessionStart hook + permission you must add by hand.
# Idempotent: safe to re-run (e.g. after `git pull`). Re-linking only; nothing destructive.
#
# Usage:
#   ./install.sh                 # link into $CLAUDE_DIR (default ~/.claude)
#   CLAUDE_DIR=~/.config/claude ./install.sh
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

say()  { printf '%s\n' "$*"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }

say "agentic.nvim → installing into: $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR"

# --- symlink the canonical files into the agent dir ------------------------
LINKS=(
  "daemon/taskloop-daemon.py"
  "daemon/taskloop-ensure.sh"
  "docs/TASKLOOP.md"
  "scripts/taskloop-clip2png.sh"
  "scripts/taskloop-prune.py"
)
say ""
say "Linking helpers:"
for rel in "${LINKS[@]}"; do
  src="$REPO/$rel"
  dst="$CLAUDE_DIR/$(basename "$rel")"
  [ -f "$src" ] || { warn "missing in repo: $rel (skipped)"; continue; }
  ln -sfn "$src" "$dst"
  case "$rel" in *.sh|*.py) chmod +x "$src" 2>/dev/null || true ;; esac
  ok "$(basename "$rel") → $rel"
done

# --- dependency checks -----------------------------------------------------
say ""
say "Dependencies:"
need() { command -v "$1" >/dev/null 2>&1; }
need claude  && ok "claude CLI found ($(command -v claude))" \
             || warn "claude CLI NOT found — workers can't launch. Install Claude Code."
need python3 && ok "python3 found ($(python3 --version 2>&1))" \
             || warn "python3 NOT found — the daemon won't run."
need git     && ok "git found" || warn "git not found (used for repo-root detection)."

if need pngpaste || need wl-paste || need xclip || need osascript; then
  tool=$(for t in pngpaste wl-paste xclip osascript; do need "$t" && { echo "$t"; break; }; done)
  ok "clipboard image tool: $tool (screenshot paste will work)"
else
  warn "no clipboard image tool (pngpaste / wl-paste / xclip / osascript) — screenshot paste disabled."
  warn "  macOS: built-in osascript, or brew install pngpaste · Wayland: wl-clipboard · X11: xclip"
fi

need nvim && ok "nvim found" || warn "nvim not found — the editor front-end needs Neovim + telescope.nvim."

# --- wire up settings.json automatically (idempotent) ----------------------
# The daemon auto-start (SessionStart hook) + the one permission workers need
# (`Bash(claude -p:*)`) are merged into settings.json for you — preserving any
# existing settings. Set AGENTIC_NO_SETTINGS=1 to skip and do it by hand.
say ""
say "Claude Code settings:"
if [ "${AGENTIC_NO_SETTINGS:-}" = "1" ]; then
  warn "AGENTIC_NO_SETTINGS=1 — skipped. Add a SessionStart hook running"
  warn "  taskloop-ensure.sh and permission \"Bash(claude -p:*)\" yourself."
elif need python3; then
  python3 - "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/taskloop-ensure.sh" <<'PY' | while read -r l; do ok "$l"; done
import json, os, sys
path, ensure = sys.argv[1], sys.argv[2]
try:
    with open(path) as f: s = json.load(f)
except Exception:
    s = {}
changed = []
allow = s.setdefault("permissions", {}).setdefault("allow", [])
if "Bash(claude -p:*)" not in allow:
    allow.append("Bash(claude -p:*)"); changed.append("permission Bash(claude -p:*)")
ss = s.setdefault("hooks", {}).setdefault("SessionStart", [])
present = any("taskloop-ensure" in h.get("command", "")
             for e in ss for h in e.get("hooks", []))
if not present:
    ss.append({"hooks": [{"type": "command", "command": f'bash "{ensure}"'}]})
    changed.append("SessionStart hook -> taskloop-ensure.sh")
if changed:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f: json.dump(s, f, indent=2); f.write("\n")
    print("settings.json: added " + "; ".join(changed))
else:
    print("settings.json: hook + permission already present")
PY
else
  warn "python3 not found — can't edit settings.json. Add the SessionStart hook +"
  warn "  permission \"Bash(claude -p:*)\" by hand."
fi

say ""
say "Notes:"
say "  • To use the loop in a repo: create an empty TASKS.md at its root."
say "  • ensure finds a loop in CWD or any ancestor (subdir loops like <repo>/ui work)."
say "  • nvim front-end loads via your lazy.nvim spec (\`dir\` → this repo) + telescope.nvim."
say ""
ok "Done. Re-run anytime — idempotent (e.g. after a git pull)."
