local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

local commands = require("bdub.commands")

local mappings = {
	["."] = { "which_key_ignore" },
	s = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
	T = {
		name = "Telescope",
		d = { commands.find_files_within_directories, "Find File in Directory" },
		s = { commands.grep_string_within_directories, "Grep String in Directory" },
		h = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
	},
	b = { "<cmd>Telescope buffers<cr>", "which_key_ignore" },
	q = { "which_key_ignore" },
	e = { "which_key_ignore" },
	f = { "which_key_ignore" },
	h = { "which_key_ignore" },
	[">"] = { "which_key_ignore" },
	["<"] = { "which_key_ignore" },
	p = { "which_key_ignore" },
	P = {
		function()
			local path = vim.fn.expand("%:.")
			print(path)
			vim.fn.setreg("+", path)
		end,
		"get relative path",
	},
	u = { "which_key_ignore" },
	w = { "which_key_ignore" },
	g = {
		name = "Git",
	},
	v = {
		name = "View",
	},
}

local normal_opts = {
	mode = "n", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

local visual_opts = {
	mode = "v", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

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
	window = {
		border = "single", -- none, single, double, shadow
		position = "bottom", -- bottom, top
		margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
		padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
	},
	layout = {
		height = { min = 4, max = 25 }, -- min and max height of the columns
		width = { min = 20, max = 50 }, -- min and max width of the columns
		spacing = 3, -- spacing between columns
	},
	ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
	hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
	show_help = true, -- show help message on the command line when the popup is visible
	triggers = "auto", -- automatically setup triggers
	-- triggers = {"<leader>"} -- or specifiy a list manually
})

which_key.register(mappings, normal_opts)
which_key.register(mappings, visual_opts)
