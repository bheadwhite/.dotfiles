local actions = require "diffview.actions"

require("diffview").setup {
  keymaps = {
    view = {
      ["<leader>Co"] = actions.conflict_choose "ours",
      ["<leader>Ct"] = actions.conflict_choose "theirs",
      ["<leader>Cb"] = actions.conflict_choose "base",
      ["<leader>Ca"] = actions.conflict_choose "all",
      ["dx"] = actions.conflict_choose "none",
    },
  },
}
