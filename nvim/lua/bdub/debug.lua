local inspect_buffer = nil

local function create_or_append_buffer(obj)
	-- Check if the buffer already exists
	if not inspect_buffer or not vim.api.nvim_buf_is_valid(inspect_buffer) then
		-- Create a new buffer if it doesn't exist or is invalid
		inspect_buffer = vim.api.nvim_create_buf(false, true) -- create a new empty buffer
		vim.api.nvim_buf_set_option(inspect_buffer, "buftype", "nofile") -- make it a scratch buffer

		-- Open the new buffer in a vertical split
		vim.cmd("vsplit")
		vim.api.nvim_win_set_buf(0, inspect_buffer)

		vim.api.nvim_buf_set_option(inspect_buffer, "filetype", "lua")
	end

	-- Populate the buffer with the inspected object
	local lines = vim.split(vim.inspect(obj), "\n")
	local line_count = vim.api.nvim_buf_line_count(inspect_buffer)
	vim.api.nvim_buf_set_lines(inspect_buffer, line_count, line_count, false, lines)
end

return create_or_append_buffer
