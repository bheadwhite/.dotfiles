local exports = {
  open_diffview = { "<cmd>DiffviewOpen<cr>", "Open DiffView" },
  close_diffview = { "<cmd>DiffviewClose<cr>", "Close Diffview" },
  choose_ours = { "<cmd>lua require 'diffview.config'.actions.conflict_choose('ours')<cr>", "Choose Ours" },
  choose_theirs = { "<cmd>lua require 'diffview.config'.actions.conflict_choose('theirs')<cr>", "Choose Theirs" },
  choose_base = { "<cmd>lua require 'diffview.config'.actions.conflict_choose('base')<cr>", "Choose Base" },
  choose_all = { "<cmd>lua require 'diffview.config'.actions.conflict_choose('all')<cr>", "Choose All" },
  restore_entry = { "<cmd>lua require 'diffview.config'.actions.restore_entry()<cr>", "Restore Entry" },
  toggle_stage_entry = { "<cmd>lua require 'diffview.config'.actions.toggle_stage_entry()<cr>", "Toggle Stage Entry" },
  choose_none = { "<cmd>lua require 'diffview.config'.actions.conflict_choose('none')<cr>", "Choose None" },
}

return exports
