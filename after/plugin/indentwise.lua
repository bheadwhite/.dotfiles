local ts_utils = require("nvim-treesitter.ts_utils")

function isNodeInSameNestedTree(node_a, node_b)
	local nextParents = {}
	local rootId = node_a:tree():root():id()
	local startParents = {}
	local parent = node_b:parent()
	local nearCap = 2

	-- get near ancestors
	while parent ~= nil and #nextParents <= nearCap do
		table.insert(nextParents, parent:id())
		parent = parent:parent()
	end

	-- get near start parents
	parent = node_a:parent()
	while parent ~= nil and #startParents <= nearCap do
		table.insert(startParents, parent:id())
		parent = parent:parent()
	end

	-- find the first parent that is in both lists
	local found = false
	for _, parentId in ipairs(nextParents) do
		if found then
			break
		end
		for _, startParentId in ipairs(startParents) do
			if parentId == startParentId and parentId ~= rootId then
				found = true
				break
			end
		end
	end

	return found
end

vim.keymap.set({ "x", "n" }, "<C-M-]>", function()
	vim.cmd("normal! ^")
	local start_line = vim.fn.line(".")
	local start_col = vim.fn.col(".")
	local start_node = ts_utils.get_node_at_cursor()
	if start_node == nil then
		return
	end

	vim.cmd('call <SNR>56_move_to_indent_depth(1, "==", 0, "n")')

	local next = ts_utils.get_node_at_cursor()
	-- if column index is 0 then return
	if vim.fn.col(".") == 1 then
		vim.cmd([[normal! zz]])
		return
	end

	local isSameNestedTree = isNodeInSameNestedTree(start_node, next)

	if isSameNestedTree then
		-- center the screen
		vim.cmd([[normal! zz]])
	else
		-- potentially im in a different nested tree
		if start_line > start_node:start() + 1 then
			vim.api.nvim_win_set_cursor(0, { start_line, start_col - 1 })
		else
			ts_utils.goto_node(start_node, false, false)
		end
	end
end, { silent = true, desc = "next indent" })
vim.keymap.set({ "x", "n" }, "<C-M-[>", function()
	vim.cmd("normal! ^")
	local node = ts_utils.get_node_at_cursor()
	if node == nil then
		return
	end

	vim.cmd('call <SNR>56_move_to_indent_depth(0, "==", 0, "n")')
	-- if column index is 0 then return
	if vim.fn.col(".") == 1 then
		vim.cmd([[normal! zz]])
		return
	end

	local next = ts_utils.get_node_at_cursor()

	local isSameNestedTree = isNodeInSameNestedTree(node, next)

	if isSameNestedTree then
		-- center the screen
		vim.cmd([[normal! zz]])
	else
		-- go back
		ts_utils.goto_node(node, false, false)
	end
end, { silent = true, desc = "prev indent" })
