local colors = require("bdub.everforest_colors")

vim.cmd([[highlight MyInactiveBufferColor guibg=]] .. colors.bg2)
vim.cmd([[highlight MyZoomedBufferColor guibg=]] .. colors.bg0)
vim.cmd([[highlight MyNormalColor guibg=]] .. colors.bg0)
vim.cmd([[highlight DuplicateBuffer guibg=]] .. "#121212")

function set_window_backgrounds()
	-- Get the current window ID
	local current_win = vim.api.nvim_get_current_win()

	-- Get a list of all window IDs
	local windows = vim.api.nvim_list_wins()

	-- Create a table to keep track of buffer names
	local buffer_names = {}

	-- Iterate through each buffer
	for _, win in ipairs(windows) do
		local win_buf = vim.api.nvim_win_get_buf(win)
		local buf_name = vim.api.nvim_buf_get_name(win_buf)
		-- local buf_name = vim.api.nvim_buf_get_name(win)
		-- If the buffer name is already in the table, mark it as a duplicate
		if buffer_names[buf_name] then
			buffer_names[buf_name] = "duplicate"
		else
			buffer_names[buf_name] = "unique"
		end
	end

	-- Iterate through each window
	for _, win in ipairs(windows) do
		-- Get the buffer displayed in the window
		local win_buf = vim.api.nvim_win_get_buf(win)
		local win_buf_name = vim.api.nvim_buf_get_name(win_buf)

		if win == current_win then
			-- Set highlight for the focused window
			vim.api.nvim_win_set_option(win, "winhighlight", "Normal:MyNormalColor")
		elseif buffer_names[win_buf_name] == "duplicate" then
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
