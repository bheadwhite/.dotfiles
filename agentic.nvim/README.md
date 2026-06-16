# agentic.nvim

An async task-board for driving background coding agents from Neovim. You queue
UI tasks; a daemon dispatches one headless `claude -p` worker per task, renders a
live read-only `STATUS.md`, and you review/rework/accept from the editor.

The nvim front-end and the daemon engine live together here on purpose — they
share a protocol contract (`[img: …]` references, the `.cancel` flag, the
`workers/T<id>` lock layout, the result-file fields). Keeping them in one repo is
what stops them drifting apart.

## Layout

```
install.sh                symlink helpers into $CLAUDE_DIR + check deps + print the hook
lua/taskloop/init.lua     nvim plugin (front-end). Loaded by lazy.nvim via `dir`.
daemon/
  task-loop-daemon2.py    the engine: dispatch, scope, reap, render, auto-retry
  task-loop-ensure2.sh    idempotent launcher (SessionStart hook + by hand)
scripts/
  taskloop-clip2png.sh    clipboard image -> PNG (macOS / Wayland / X11)
  taskloop-prune.py       drop consumed verdicts from REVIEW.md
docs/
  TASKLOOP2.md            the v2 protocol / file-ownership spec
```

## Install

This repo is vendored inside the dotfiles tree (`~/.dotfiles/agentic.nvim`). The
daemon and helper scripts are referenced by path from the agent dir (default
`~/.claude`), so they're **symlinked** there. `install.sh` does the linking, checks
dependencies, and prints the SessionStart hook + permission you must add by hand
(an agent can't self-grant a worker-launching hook):

```sh
./install.sh                      # link into ~/.claude
CLAUDE_DIR=~/.config/claude ./install.sh   # or wherever you keep agent config
```

Re-run it after a `git pull`. The nvim plugin is loaded straight from this repo —
the lazy.nvim spec (`~/.dotfiles/nvim/lua/plugins/taskloop.lua`) points `dir` here.

### Configuration (all optional)

| Knob | Default | Effect |
|---|---|---|
| `CLAUDE_DIR` (env) | `~/.claude` | where helpers are symlinked + looked up (daemon, ensure, plugin all honor it) |
| `TASKLOOP_EXCLUDE_MD` (env) | *(none)* | comma-list of global CLAUDE.md files to drop from worker context; a literal `$CLAUDE_DIR` token is expanded |
| `setup({ claude_dir = … })` (nvim) | `$CLAUDE_DIR` or `~/.claude` | plugin's helper-script location |
| `--worker-model / --scope-model / --max-workers / --exclude-md` | see `task-loop-daemon2.py` header | daemon tunables |

The ensure script resolves the repo root from the **nearest ancestor of `$PWD`
holding a `TASKS.md`** (so a loop in a subdir like `<repo>/ui` is found), falling
back to the git root — or pass an explicit root: `task-loop-ensure2.sh /path/to/repo`.

### Dependencies

`claude` CLI + `python3` (required); `nvim` + `telescope.nvim` (front-end); a
clipboard image tool for screenshot paste — `pngpaste`/`osascript` (macOS),
`wl-clipboard` (Wayland), or `xclip` (X11).

## Per-repo state (not in this repo)

Each project that uses the loop gets its own `.taskloop/` (state, logs, worker
locks), plus `TASKS.md` (you write), `STATUS.md` (daemon renders), `REVIEW.md`
(you write verdicts). See `docs/TASKLOOP2.md` for file ownership.
