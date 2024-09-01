local colors = require("bdub.everforest_colors")
local utils = require("bdub.win_utils")

vim.cmd([[highlight MyInactiveBufferColor guibg=]] .. colors.bg2)
vim.cmd([[highlight MyZoomedBufferColor guibg=]] .. colors.bg0)
vim.cmd([[highlight MyNormalColor guibg=]] .. colors.bg0)
vim.cmd([[highlight DuplicateBuffer guibg=]] .. colors.bg_green)
vim.cmd([[highlight CursorLine guibg=]] .. colors.bg_green)

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function()
    utils.set_window_backgrounds()
  end,
})

-- Call the function to apply the highlights initially
utils.set_window_backgrounds()

local zoomed = false
vim.keymap.set("n", "<leader>z", function()
  vim.cmd("ZoomWinTabToggle")
end, { noremap = true, silent = true, desc = "zoom" })

return {
  get_zoom = function()
    return zoomed
  end,
}
