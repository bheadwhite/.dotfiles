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
  vim.cmd("ZoomWinTabToggle")
end, { noremap = true, silent = true, desc = "zoom in" })
-- vim.keymap.set("n", "<leader>z", function()
--   vim.cmd("WindowsMaximize")
-- end, { noremap = true, silent = true, desc = "zoom in" })

return {
  get_zoom = function()
    return zoomed
  end,
}
