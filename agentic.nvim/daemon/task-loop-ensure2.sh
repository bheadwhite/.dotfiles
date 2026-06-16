#!/usr/bin/env bash
# Ensure the TASK-LOOP v2 daemon is running for a repo (idempotent).
# Called by a SessionStart hook (startup/resume/compact) and safe to run by hand.
# v2 never rewrites the user's TASKS.md/REVIEW.md — it renders STATUS.md and
# dispatches headless `claude -p` workers. See ~/.claude/TASKLOOP2.md.
#
# Usage: task-loop-ensure2.sh [REPO_ROOT]
#   REPO_ROOT given      -> use it verbatim.
#   omitted              -> the nearest ancestor of $PWD that has a TASKS.md (so a loop
#                           living in a subdir, e.g. <repo>/ui, is found from a session
#                           started there); else the git root; else $PWD.
# $CLAUDE_DIR (default ~/.claude) is where the daemon is symlinked.

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
DAEMON="$CLAUDE_DIR/task-loop-daemon2.py"

resolve_root() {
  if [ -n "$1" ]; then printf '%s\n' "$1"; return; fi
  local d="$PWD"
  while [ "$d" != "/" ] && [ -n "$d" ]; do
    [ -f "$d/TASKS.md" ] && { printf '%s\n' "$d"; return; }
    d="$(dirname "$d")"
  done
  git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$PWD"
}
ROOT="$(resolve_root "${1:-}")"

# Only act in repos that use the loop, and only if the daemon exists.
[ -f "$ROOT/TASKS.md" ] && [ -f "$DAEMON" ] || exit 0

# Already running for this repo? Do nothing. (The daemon also holds a lifetime
# flock on .taskloop/.daemon.lock as the real single-instance guard.)
pgrep -f "task-loop-daemon2.py $ROOT" >/dev/null 2>&1 && exit 0

mkdir -p "$ROOT/.taskloop"
# Detached + self-looping. Kill switch: pkill -f task-loop-daemon2.py
# stdout carries the edge-triggered "BLOCKED — needs you" line → into loop.log,
# which the nvim plugin tails to notify you.
nohup python3 "$DAEMON" "$ROOT" >> "$ROOT/.taskloop/loop.log" 2>&1 &
exit 0
