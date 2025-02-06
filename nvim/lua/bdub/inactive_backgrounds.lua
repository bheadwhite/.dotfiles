local utils = require("bdub.win_utils")

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function()
    utils.set_window_backgrounds()
  end,
})

-- Call the function to apply the highlights initially
utils.set_window_backgrounds()

local zoomed = false
vim.keymap.set("n", "<leader>z", function()
  local buf = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd("tabnew")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end, { noremap = true, silent = true, desc = "zoom in" })
-- vim.keymap.set("n", "<leader>z", function()
--   vim.cmd("WindowsMaximize")
-- end, { noremap = true, silent = true, desc = "zoom in" })

return {
  get_zoom = function()
    return zoomed
  end,
}
