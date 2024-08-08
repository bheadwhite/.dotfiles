local colors = require("bdub.everforest_colors")
local utils = require("bdub.win_utils")

vim.cmd([[highlight MyInactiveBufferColor guibg=]] .. colors.bg2)
vim.cmd([[highlight MyZoomedBufferColor guibg=]] .. colors.bg0)
vim.cmd([[highlight MyNormalColor guibg=]] .. colors.bg0)
vim.cmd([[highlight DuplicateBuffer guibg=]] .. colors.bg_green)

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	callback = function()
		utils.set_window_backgrounds()
	end,
})

-- Call the function to apply the highlights initially
utils.set_window_backgrounds()

local zoomed = false
local function open_in_floating_window()
	zoomed = not zoomed
	require("mini.misc").zoom()
	if zoomed then
		vim.cmd("set winhighlight=Normal:MyZoomedBufferColor")
	else
		vim.cmd("set winhighlight=Normal:MyNormalColor")
	end
end

vim.keymap.set("n", "<leader>z", function()
	open_in_floating_window()
end, { noremap = true, silent = true, desc = "zoom" })

return {
	get_zoom = function()
		return zoomed
	end,
}
