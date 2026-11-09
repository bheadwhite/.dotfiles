-- Next Edit Suggestions only. Chatting with Claude lives in
-- lua/plugins/claudecode.lua; <C-M-F14> (lua/plugins/copilot.lua) applies NES.
return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    -- Next Edit Suggestions (NES) configuration
    nes = {
      enabled = true,
      diff = {
        inline = "words", -- Enable inline word-level diffs
      },
      trigger = {
        events = { "ModeChanged i:n", "TextChanged", "User SidekickNesDone" },
      },
    },
    -- Copilot status tracking
    copilot = {
      status = {
        enabled = true,
        level = vim.log.levels.WARN,
      },
    },
  },
}
