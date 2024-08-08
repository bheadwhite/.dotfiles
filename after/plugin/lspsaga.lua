require("lspsaga").setup({
	symbol_in_winbar = {
		enable = true,
	},
	beacon = {
		enable = true,
	},
})

-- function isLspSagaActive()
-- 	local lspsaga_win_id = require("lspsaga.window").winid
-- 	local windows = vim.api.nvim_list_wins()
-- 	-- if list of windows contains lspsaga window, remove it
--ku 	for i, win in ipairs(windows) do
-- 		if win == lspsaga_win_id then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- function debounce(callback, delay)
-- 	local timer = nil
-- 	return function(...)
-- 		local args = { ... }
-- 		if timer then
-- 			timer:stop()
-- 		end
-- 		timer = vim.defer_fn(function()
-- 			callback(unpack(args))
-- 		end, delay)
-- 	end
-- end
--
-- local lastId = ""
--
-- local function on_cursor_hold()
-- 	local ts_utils = require("nvim-treesitter.ts_utils")
--
-- 	-- Check if lspsaga is active
-- 	if isLspSagaActive() then
-- 		return
-- 	end
--
-- 	local node = ts_utils.get_node_at_cursor()
-- 	if node == nil then
-- 		return
-- 	end
--
-- 	if node:id() == lastId then
-- 		return
-- 	end
--
-- 	lastId = node:id()
--
-- 	local hasError = node:has_error()
-- 	if hasError then
-- 		return
-- 	end
--
-- 	local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
-- 	if #diagnostics > 0 then
-- 		return
-- 	end
--
-- 	vim.cmd([[Lspsaga hover_doc]])
-- end
--
-- local hover_debounce = debounce(on_cursor_hold, 2000)

-- vim.api.nvim_create_autocmd("CursorHold", {
-- 	callback = hover_debounce,
-- })
