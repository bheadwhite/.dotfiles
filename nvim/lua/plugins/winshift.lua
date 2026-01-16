return {
  "sindrets/winshift.nvim",
  -- move windows around
  cond = not vim.g.vscode,
  config = function()
    vim.keymap.set("n", "<C-M-w>", vim.cmd.WinShift, { desc = "winshift" })
  end,
}
