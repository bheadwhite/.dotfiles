# CLAUDE.md — developing agentic.nvim

This repo is the **engine + Neovim front-end + Claude Code plugin** for the
agentic task-board. (To *use* the board, the `agentic` skill is the guide; this
file is for working *on* the repo.)

## Layout

```
.claude-plugin/plugin.json       Claude Code plugin manifest
.claude-plugin/marketplace.json  so it installs via /plugin marketplace add
skills/agentic/SKILL.md          how to operate the board (the user-facing how-to)
commands/                        slash commands (e.g. /task-loop-status)
hooks/hooks.json                 SessionStart -> ensure the daemon is running
daemon/taskloop-daemon.py      the engine: dispatch / scope / reap / render / auto-retry
daemon/taskloop-ensure.sh      idempotent launcher
scripts/                         taskloop-clip2png.sh, taskloop-prune.py
docs/TASKLOOP.md                the protocol / file-ownership spec
lua/taskloop/init.lua            the Neovim plugin (loaded by lazy.nvim via `dir`)
install.sh                       symlinks daemon/scripts into ~/.claude
```

## How it installs

Two delivery paths, both pointing at this one repo:

- **Engine + knowledge** → as a Claude Code plugin (`/plugin marketplace add` this
  repo, then install `agentic-nvim`), which gives any session the `agentic` skill,
  the `/task-loop-status` command, and the SessionStart hook. `install.sh` also
  symlinks `daemon/`+`scripts/` into `~/.claude` (the daemon/ensure reference those
  paths) and prints the manual settings step.
- **Editor front-end** → Neovim, via a lazy.nvim spec whose `dir` points here
  (`require("taskloop").setup{…}`). Not delivered by the Claude plugin.

## Conventions / gotchas

- **History:** this came from a v1→v2 rewrite (v1 made the daemon the sole writer of
  a file the user also edited → churn; v2 = one writer per file). v1 and the legacy
  `2` suffix are gone — the files are `taskloop-daemon.py` / `taskloop-ensure.sh` /
  `docs/TASKLOOP.md`. (The daemon's internal `DAEMON2 START` log label is cosmetic.)
- **The daemon runs live** against real repos (e.g. room303, mfe-lib). Editing a
  `daemon/*.py` file does NOT affect running daemons until they restart
  (`pkill -f taskloop-daemon.py` then re-ensure). Don't restart mid-task without
  reason.
- `~/.claude/*` are **symlinks** into this repo (via `install.sh`); edit the repo
  files, not the symlinks. Per-repo state (`.taskloop/`, `STATUS.md`, …) is never
  committed here.
