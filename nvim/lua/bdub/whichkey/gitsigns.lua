local exports = {
  blame = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
  reset_hunk = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
  reset_buffer = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
  stage_hunk = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
  preview_hunk = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "preview hunk" },
  undo_stage_hunk = { "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", "Undo Stage Hunk" },
  diff = { "<cmd>Gitsigns diffthis HEAD<cr>", "Diff" },
}

return exports
