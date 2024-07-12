local colors = require("bdub.everforest_colors")
local utils = require("bdub.win_utils")

vim.cmd([[highlight MyInactiveBufferColor guibg=]] .. colors.bg2)
vim.cmd([[highlight MyZoomedBufferColor guibg=]] .. colors.bg0)
vim.cmd([[highlight MyNormalColor guibg=]] .. colors.bg0)
vim.cmd([[highlight DuplicateBuffer guibg=]] .. "#121212")

function set_window_backgrounds()
	-- Get the current window ID
	local current_win = vim.api.nvim_get_current_win()

	-- Get a list of all window IDs
	local windows = vim.api.nvim_list_wins()

	-- get duplicate win buffers
	local duplicates = utils.get_duplicate_win_buffers()

	-- Iterate through each window
	for _, win in ipairs(windows) do
		if win == current_win then
			-- Set highlight for the focused window
			vim.api.nvim_win_set_option(win, "winhighlight", "Normal:MyNormalColor")
		elseif utils.is_duplicate_win(win, duplicates) then
			-- Set highlight for windows displaying duplicate buffers
			vim.api.nvim_win_set_option(win, "winhighlight", "Normal:DuplicateBuffer")
		else
			-- Set highlight for the unfocused windows
			vim.api.nvim_win_set_option(win, "winhighlight", "Normal:MyInactiveBufferColor")
		end
	end
end

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	callback = function()
		set_window_backgrounds()
	end,
})

-- Call the function to apply the highlights initially
set_window_backgrounds()

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
