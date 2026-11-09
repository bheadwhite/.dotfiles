-- Claude Code over its IDE protocol (the same one the VS Code / JetBrains
-- extensions speak). Once the CLI connects, Claude sees your current selection
-- live, can list open buffers and read their diagnostics, and proposes edits as
-- native diffs you accept/deny -- no pasting context into a terminal.
--
-- Next-edit suggestions stay with sidekick (lua/plugins/sidekick.lua).

-- Point Claude at what you're looking at, then jump into its prompt to ask.
-- Visual mode: the selection. Normal mode: the line under the cursor.
-- Either way it lands as an @file#Lx-y mention in Claude's input box.
local function point_claude_here()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("ClaudeCodeSend")
    return
  end
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" or vim.bo.buftype ~= "" then
    vim.cmd("ClaudeCodeFocus")
    return
  end
  local line = tostring(vim.api.nvim_win_get_cursor(0)[1])
  vim.cmd({ cmd = "ClaudeCodeAdd", args = { path, line, line } })
end

-- caps+space. Resolved at spec-load time because lazy.nvim reads `keys` eagerly.
local ok_bdub, bdub = pcall(require, "bdub")
local hyper_space = ok_bdub and bdub.hyper_space_key or nil

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  -- Load up front so the IDE server is listening (and tracking selection)
  -- before the first keypress, including for a `claude` started in another pane.
  event = "VeryLazy",
  opts = {
    -- Every send/add moves you into Claude's prompt so you can type the question.
    focus_after_send = true,
    terminal = {
      split_side = "right",
      split_width_percentage = 0.35,
    },
  },
  keys = {
    { "<leader>a", nil, desc = "Claude Code" },
    { hyper_space or "<Nop>", point_claude_here, mode = { "n", "x" }, desc = "Point Claude here (caps+space)" },
    { "<leader>aa", point_claude_here, mode = { "n", "x" }, desc = "Point Claude here" },
    { "<leader>at", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>ao", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude session" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue last Claude session" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>af", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current file to Claude" },
    { "<leader>af", "<cmd>ClaudeCodeTreeAdd<cr>", ft = { "oil" }, desc = "Add file under cursor to Claude" },
    { "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude's diff" },
    { "<leader>an", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject Claude's diff" },
  },
}
