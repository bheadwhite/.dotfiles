local ts_utils = require("nvim-treesitter.ts_utils")
local M = {}

function M.go_next_column()
	vim.cmd("normal! ^")
	local node = ts_utils.get_node_at_cursor()
	if node == nil then
		return
	end

	local next = node:next_named_sibling()
	if node:type() == "if_statement" then
		-- find the child that is a elif_clause or else_clause
		local children = ts_utils.get_named_children(node)
		for _, child in ipairs(children) do
			if child:type() == "elif_clause" or child:type() == "else_clause" then
				next = child
				break
			end
		end
	end

	if next == nil then
		if next == nil then
			return
		end
	end

	ts_utils.goto_node(next, false, false)

	vim.cmd([[normal! zz]])
end

function M.go_to_previous_column()
	vim.cmd("normal! ^")
	local node = ts_utils.get_node_at_cursor()
	if node == nil then
		return
	end

	local prev = node:prev_named_sibling()
	if node:type() == "elif_clause" or node:type() == "else_clause" then
		if prev:type() == "elif_clause" or prev:type() == "else_clause" then
		--noop
		else
			prev = node:parent()
		end
	end

	if prev == nil then
		return
	end

	ts_utils.goto_node(prev, false, false)

	vim.cmd([[normal! zz]])
end

return M
