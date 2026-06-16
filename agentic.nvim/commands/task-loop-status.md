---
description: Show the task-loop STATUS board for the current repo (and start the daemon if needed).
disable-model-invocation: true
---

# Task-loop status

Ensure the daemon is running, then show the board.

```!
bash "${CLAUDE_PLUGIN_ROOT}/daemon/task-loop-ensure2.sh" "${CLAUDE_PROJECT_DIR}" >/dev/null 2>&1
f="${CLAUDE_PROJECT_DIR}/STATUS.md"; [ -f "$f" ] && cat "$f" || echo "No STATUS.md — is this a task-loop repo? (needs TASKS.md)"
```

Summarize what's waiting in **✅ Verify** (needs the user), what's **🔧 Doing**, and
anything **⛔ Blocked** or **⏳ Rate-limited**. Offer to accept/rework verify items.
