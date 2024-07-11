local colors = require("bdub.everforest_colors")

vim.cmd([[highlight MyInactiveBufferColor guibg=]] .. colors.bg2)
vim.cmd([[highlight MyZoomedBufferColor guibg=]] .. colors.bg0)
vim.cmd([[highlight MyNormalColor guibg=]] .. colors.bg0)
-- background color of the current buffer
-- Function to set the background color of the current buffer
local function set_current_buffer_highlight()
	local bufnr = vim.api.nvim_get_current_buf()

	vim.api.nvim_buf_set_option(bufnr, "winhighlight", "Normal:MyNormalColor")
end

-- Function to clear the background color of non-current buffers
-- local function clear_buffer_highlight()
-- 	local buffers = vim.api.nvim_list_bufs()
--
-- 	for _, bufnr in ipairs(buffers) do
-- 		vim.api.nvim_buf_set_option(bufnr, "winhighlight", "Normal:MyInactiveBufferColor")
-- 	end
-- end
--
-- -- Function to update buffer highlights
-- local function update_buffer_highlights()
-- 	clear_buffer_highlight()
-- 	set_current_buffer_highlight()
-- end
--
-- -- Autocommand to update buffer highlights when changing buffer
--
-- -- Set initial highlight
-- update_buffer_highlights()
-- Function to set window highlights
local function set_window_highlights()
	-- Get the current window ID
	local current_win = vim.api.nvim_get_current_win()

	-- Get a list of all window IDs
	local windows = vim.api.nvim_list_wins()

	-- Iterate through each window
	for _, win in ipairs(windows) do
		if win == current_win then
			-- Set highlight for the focused window
			vim.api.nvim_win_set_option(win, "winhighlight", "Normal:MyNormalColor")
		else
			-- Set highlight for the unfocused windows
			vim.api.nvim_win_set_option(win, "winhighlight", "Normal:MyInactiveBufferColor")
		end
	end
end

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	callback = function()
		set_window_highlights()
	end,
})

-- Call the function to apply the highlights initially
set_window_highlights()

-- Set an autocommand to reapply the highlights when changing focus
-- vim.api.nvim_exec(
-- 	[[
--   augroup UpdateWindowHighlights
--     autocmd!
--     autocmd WinEnter,BufEnter * lua set_window_highlights()
--   augroup END
-- ]],
-- 	false
-- )

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
