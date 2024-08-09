return {
	"folke/which-key.nvim",
	config = function()
		local which_key = require("which-key")
		local commands = require("bdub.commands")
		local mappings = {
			{
				mode = { "v", "n" },
				{
					"<leader>P",
					function()
						local path = vim.fn.expand("%:.")
						print(path)
						vim.fn.setreg("+", path)
					end,
					desc = "get relative path",
					nowait = true,
					remap = false,
				},
				{
					"<leader>T",
					group = "Telescope",
					nowait = true,
					remap = false,
				},
				{
					"<leader>Td",
					commands.find_files_within_directories,
					desc = "Find File in Directory",
					nowait = true,
					remap = false,
				},
				{
					"<leader>Th",
					"<cmd>Telescope help_tags<cr>",
					desc = "Help Tags",
					nowait = true,
					remap = false,
				},
				{
					"<leader>Ts",
					commands.grep_string_within_directories,
					desc = "Grep String in Directory",
					nowait = true,
					remap = false,
				},
				{
					"<leader>b",
					commands.list_buffers,
					hidden = true,
					nowait = true,
					remap = false,
				},
				{
					"<leader>v",
					group = "View",
					nowait = true,
					remap = false,
				},
			},
		}

		-- local normal_opts = {
		-- 	mode = "n", -- NORMAL mode
		-- 	prefix = "<leader>",
		-- 	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
		-- 	silent = true, -- use `silent` when creating keymaps
		-- 	noremap = true, -- use `noremap` when creating keymaps
		-- 	nowait = true, -- use `nowait` when creating keymaps
		-- }
		--
		-- local visual_opts = {
		-- 	mode = "v", -- NORMAL mode
		-- 	prefix = "<leader>",
		-- 	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
		-- 	silent = true, -- use `silent` when creating keymaps
		-- 	noremap = true, -- use `noremap` when creating keymaps
		-- 	nowait = true, -- use `nowait` when creating keymaps
		-- }

		which_key.setup({
			plugins = {
				marks = true, -- shows a list of your marks on ' and `
				registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
				presets = {
					operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
					motions = false, -- adds help for motions
					text_objects = false, -- help for text objects triggered after entering an operator
					windows = false, -- default bindings on <c-w>
					nav = false, -- misc bindings to work with windows
					z = false, -- bindings for folds, spelling and others prefixed with z
					g = false, -- bindings for prefixed with g
				},
			},
			-- window = {
			-- 	border = "single", -- none, single, double, shadow
			-- 	position = "bottom", -- bottom, top
			-- 	margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
			-- 	padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
			-- },
			layout = {
				height = { min = 4, max = 25 }, -- min and max height of the columns
				width = { min = 20, max = 50 }, -- min and max width of the columns
				spacing = 3, -- spacing between columns
			},
			-- ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
			-- hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
			show_help = true, -- show help message on the command line when the popup is visible
			-- triggers = "auto", -- automatically setup triggers
			-- triggers = {"<leader>"} -- or specifiy a list manually
		})

		which_key.add(mappings)
	end,
}
