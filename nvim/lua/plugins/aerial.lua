local lua_utils = require("bdub.lua_utils")
local colors = require("bdub.everforest_colors")

local function sort_with_priority(symbols)
	-- Define a priority order
	local priority_keywords = {
		-- "__init__",
	}

	-- Define a less priority order
	local less_priority_keywords = {
		"_",
		"Get",
		"List",
		"Create",
		"Update",
		"Delete",
	}

	-- Comparator function
	local function comparator(a, b)
		local a_priority = lua_utils.matches_any(a.name, priority_keywords) and 1
			or (lua_utils.matches_any(a.name, less_priority_keywords) and 3 or 2)
		local b_priority = lua_utils.matches_any(b.name, priority_keywords) and 1
			or (lua_utils.matches_any(b.name, less_priority_keywords) and 3 or 2)

		if a_priority == b_priority then
			return a.name < b.name
		else
			return a_priority < b_priority
		end
	end

	table.sort(symbols, comparator)
end

return {
	"stevearc/aerial.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("aerial").setup({
			layout = {
				max_width = { 100, 0.3 },
				width = 100,
				min_width = 100,
			},
			highlight_mode = "full_width",
			close_automatic_events = {
				"unfocus",
			},
			post_parse_symbol = function(bufnr, item, ctx)
				local line = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]
				if line == nil then
					return true
				end

				local keywords = { " protected", " private ", " action ", " constructor" }
				for _, keyword in ipairs(keywords) do
					if string.match(line, keyword) then
						return false
					end
				end

				return true
			end,
			post_add_all_symbols = function(bufnr, symbols, ctx)
				-- sort symbols by name

				for _, symbol in ipairs(symbols) do
					if symbol.kind == "Class" then
						sort_with_priority(symbol.children)
					end
				end

				return symbols
			end,
		})

		vim.cmd("highlight AerialLine guibg=" .. colors.red .. " guifg=" .. colors.fg)

		vim.keymap.set("n", "<C-M-a>", function()
			vim.cmd("Telescope aerial")
		end, { silent = true, desc = "aerial toggle" })
	end,
}
