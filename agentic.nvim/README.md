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
  taskloop-daemon.py    the engine: dispatch, scope, reap, render, auto-retry
  taskloop-ensure.sh    idempotent launcher (SessionStart hook + by hand)
scripts/
  taskloop-clip2png.sh    clipboard image -> PNG (macOS / Wayland / X11)
  taskloop-prune.py       drop consumed verdicts from REVIEW.md
docs/
  TASKLOOP.md            the v2 protocol / file-ownership spec
```

## Install

One command. `install.sh` symlinks the daemon + helper scripts into the agent dir
(default `~/.claude`), checks dependencies, **and merges the SessionStart hook +
the `Bash(claude -p:*)` permission into `settings.json` for you** (idempotent —
existing settings are preserved):

```sh
./install.sh                      # link into ~/.claude + wire settings.json
CLAUDE_DIR=~/.config/claude ./install.sh   # or wherever you keep agent config
AGENTIC_NO_SETTINGS=1 ./install.sh          # skip the settings merge (do it by hand)
```

That's it — re-run anytime (e.g. after a `git pull`). The nvim plugin loads
straight from this repo: the lazy.nvim spec
(`~/.dotfiles/nvim/lua/plugins/taskloop.lua`) points `dir` here (needs
`telescope.nvim`). To use the loop in a project, create an empty `TASKS.md` at its
root; the daemon auto-starts there on your next session.

### Configuration (all optional)

| Knob | Default | Effect |
|---|---|---|
| `CLAUDE_DIR` (env) | `~/.claude` | where helpers are symlinked + looked up (daemon, ensure, plugin all honor it) |
| `TASKLOOP_EXCLUDE_MD` (env) | *(none)* | comma-list of global CLAUDE.md files to drop from worker context; a literal `$CLAUDE_DIR` token is expanded |
| `setup({ claude_dir = … })` (nvim) | `$CLAUDE_DIR` or `~/.claude` | plugin's helper-script location |
| `--worker-model / --scope-model / --max-workers / --exclude-md` | see `taskloop-daemon.py` header | daemon tunables |

The ensure script resolves the repo root from the **nearest ancestor of `$PWD`
holding a `TASKS.md`** (so a loop in a subdir like `<repo>/ui` is found), falling
back to the git root — or pass an explicit root: `taskloop-ensure.sh /path/to/repo`.

### Dependencies

`claude` CLI + `python3` (required); `nvim` + `telescope.nvim` (front-end); a
clipboard image tool for screenshot paste — `pngpaste`/`osascript` (macOS),
`wl-clipboard` (Wayland), or `xclip` (X11).

## Per-repo state (not in this repo)

Each project that uses the loop gets its own `.taskloop/` (state, logs, worker
locks), plus `TASKS.md` (you write), `STATUS.md` (daemon renders), `REVIEW.md`
(you write verdicts). See `docs/TASKLOOP.md` for file ownership.
