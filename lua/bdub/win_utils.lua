local lua_utils = require("bdub.lua_utils")
local WinUtils = {}

function WinUtils.get_duplicate_win_buffers()
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

	return buffer_names
end

function WinUtils.get_win_buffers_with_duplicates()
	local duplicates_table = {}
	local windows = vim.api.nvim_list_wins()

	for _, win in ipairs(windows) do
		local win_buf = vim.api.nvim_win_get_buf(win)
		local buf_name = vim.api.nvim_buf_get_name(win_buf)

		if not duplicates_table[buf_name] then
			duplicates_table[buf_name] = { win }
		end

		table.insert(duplicates_table[buf_name], win)
	end

	for buffer_name, win_list in pairs(duplicates_table) do
		local deduped = lua_utils.deduplicate_list(win_list)
		duplicates_table[buffer_name] = deduped
	end

	return duplicates_table
end

function WinUtils.close_all_duplicates()
	local duplicates_table = WinUtils.get_win_buffers_with_duplicates()
	local didClose = false
	for _, win_list in pairs(duplicates_table) do
		if #win_list > 1 then
			for i = 2, #win_list do
				didClose = true
				vim.api.nvim_win_close(win_list[i], true)
			end
		end
	end

	return didClose
end

function WinUtils.is_duplicate_win(win, duplicateTable)
	-- Get the buffer displayed in the window
	local win_buf = vim.api.nvim_win_get_buf(win)
	local win_buf_name = vim.api.nvim_buf_get_name(win_buf)

	return duplicateTable[win_buf_name] == "duplicate"
end

return WinUtils
