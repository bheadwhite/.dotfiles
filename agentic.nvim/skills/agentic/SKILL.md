---
name: agentic
description: >-
  Async task-board for driving background coding agents. Use when the user wants
  to start/resume the task loop, queue UI/coding tasks for background workers,
  "work via the board", review/accept/rework dispatched work, or set up TASKS.md
  in a repo. The daemon runs headless `claude -p` workers; a Neovim front-end
  (agentic.nvim) drives it.
---

# agentic — async task-board

A file-based board with **one writer per file**, joined by a `[#NN]` id:

| File | Writer | Reader | Holds |
|---|---|---|---|
| `TASKS.md` | **user** (via the nvim plugin) | daemon | task list: `### <title> {tags} [#NN]` + body |
| `STATUS.md` | **daemon** (regenerated each tick) | user | live status + per-task evidence (read-only) |
| `REVIEW.md` | **user** (via the plugin) | daemon | verdicts: `#NN gg` (accept) · `#NN <note>` (rework) · `#NN ?<q>` |

The daemon dispatches one headless `claude -p` worker per task, schedules them in
parallel by a file-lock "claim" model (tasks whose files can't be predicted run
exclusively), reaps results into `STATUS.md`, and auto-retries rate-limited runs.
Full protocol: `~/.claude/TASKLOOP.md` (repo: `docs/TASKLOOP.md`).

## Bootstrap the loop in a repo

1. Ensure the daemon is running (idempotent):
   `bash ~/.claude/taskloop-ensure.sh /path/to/repo` — or just rely on the
   SessionStart hook this plugin installs. It no-ops if already running and only
   acts in repos that have a `TASKS.md`.
2. Create `TASKS.md` at the repo root if absent (an empty file is fine).
3. Add tasks via the editor (below) or by appending `### <title>` blocks; the
   daemon stamps the `[#NN]` id.

## Neovim front-end (keymaps; prefix is the hyper key `<C-A-…>`)

- `<prefix>t` — tasks picker (telescope) · `<prefix>n` — new task
- `<prefix>f` — feedback/rework the task under cursor · `<prefix>a` — accept (`gg`)
- `<prefix>,` — tail the task's worker log (vsplit) · `<prefix>s` — open STATUS.md
- `<prefix>c` — kill the worker under cursor · `<prefix>r` — restart it (kill + re-queue)
- `<prefix>u` — prune consumed verdicts · **Cmd+V** — paste a clipboard screenshot
  into a composer as `[image #N]` (expands to `[img: …]` on submit)

## Reviewing dispatched work

Finished tasks land in **✅ Verify** in `STATUS.md` with what-changed + steps. You
verify, then:
- **accept** → `#NN gg` (plugin `<prefix>a`),
- **rework** → `#NN <what's wrong>` (plugin `<prefix>f`); the worker re-runs with
  the full thread + your note,
- **question** → `#NN ?<text>` (answered in chat, not by a worker).

## Verifying runtime/visual behavior (important)

Workers can't see the browser. For UI/runtime behavior, the **user is the sensor**.
If a fix's correctness depends on something only visible at runtime (DOM, events,
styling, selection — e.g. a shadow-DOM MFE), don't guess: have the worker
**instrument** with `console.log('[probe]', JSON.stringify({…}))`, tell the user
the exact action to trigger it, and paste the line back as a rework note. Then fix
from that signal.
