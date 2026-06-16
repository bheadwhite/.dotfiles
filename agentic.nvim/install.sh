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
  "daemon/task-loop-daemon2.py"
  "daemon/task-loop-ensure2.sh"
  "docs/TASKLOOP2.md"
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

# --- the part the user must wire up themselves -----------------------------
ESC_DIR=$(printf '%q' "$CLAUDE_DIR")
say ""
say "── Manual step (agents can't self-grant this) ───────────────────────────"
say "Add to your Claude Code settings (~/.claude/settings.json or a project's"
say ".claude/settings.local.json) so the daemon auto-starts and workers can run:"
cat <<EOF

  {
    "permissions": { "allow": ["Bash(claude -p:*)"] },
    "hooks": {
      "SessionStart": [
        { "hooks": [ { "type": "command",
          "command": "CLAUDE_DIR=$ESC_DIR bash $ESC_DIR/task-loop-ensure2.sh" } ] }
      ]
    }
  }

EOF
say "  • The ensure script finds a loop in the CWD or any ancestor (so subdir"
say "    loops like <repo>/ui work). Pass an explicit root to override:"
say "      bash $CLAUDE_DIR/task-loop-ensure2.sh /path/to/repo"
say "  • Optional: export TASKLOOP_EXCLUDE_MD=\"\$CLAUDE_DIR/CLAUDE.md,…\" to trim"
say "    worker context (default: none)."
say "  • nvim: the lazy.nvim spec points \`dir\` at this repo; if you keep the"
say "    agent dir elsewhere, pass setup({ claude_dir = \"$CLAUDE_DIR\" })."
say ""
ok "Done. Re-run after a git pull to refresh links."
