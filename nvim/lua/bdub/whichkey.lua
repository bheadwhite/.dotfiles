local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

local mappings = {
	["a"] = { "<cmd>Alpha<cr>", "Alpha" },
	["b"] = {
		"<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>",
		"Buffers",
	},
	["c"] = { "<cmd>Bdelete!<CR>", "Close Buffer" },
	["e"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
	["f"] = { "<cmd>lua require'telescope.builtin'.find_files()<cr>", "Find files" },
	["F"] = { "<cmd>Telescope live_grep theme=ivy<cr>", "Find Text" },
	["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
	["H"] = { "<cmd>lua vim.lsp.buf.hover()<CR>", "hover" },
	["i"] = { "<cmd>lua require'telescope.builtin'.lsp_definitions()<cr>", "go to definitions" },
	["o"] = { "<cmd>%bd|e#|bd#<cr>", "close all but this one" },
	["p"] = { "<cmd>Telescope oldfiles<cr>", "recent" },
	["q"] = { "<cmd>q!<CR>", "Quit" },
	["r"] = { "<cmd>lua require'telescope.builtin'.lsp_references()<cr>", "go to references" },
	["T"] = { "<cmd>lua require'telescope.builtin'.lsp_type_definitions()<cr>", "go to type definition" },
	["u"] = { "<cmd>UndotreeToggle<cr>", "undo tree" },
	["."] = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
	["w"] = { "<cmd>w!<CR>", "Save" },
	["z"] = { ":MaximizerToggle<CR>", "zoom" },

	P = {
		name = "Packer",
		c = { "<cmd>PackerCompile<cr>", "Compile" },
		i = { "<cmd>PackerInstall<cr>", "Install" },
		s = { "<cmd>PackerSync<cr>", "Sync" },
		S = { "<cmd>PackerStatus<cr>", "Status" },
		u = { "<cmd>PackerUpdate<cr>", "Update" },
	},
	k = {
		name = "harpoon",
		k = { "<cmd>lua require'harpoon.ui'.toggle_quick_menu()<cr>", "menu" },
		a = { "<cmd>lua require'harpoon.mark'.add_file()<cr>", "add file" },
	},
	g = {
		name = "Git",
		g = { "<cmd>lua _LAZYGIT_TOGGLE()<CR>", "Lazygit" },
		j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
		k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
		l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
		p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
		r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
		R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
		s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
		S = { "<cmd>lua require 'telescope.builtin'.git_status()<cr>", "git status" },
		u = { "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", "Undo Stage Hunk" },
		o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
		b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
		c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
		d = { "<cmd>Gitsigns diffthis HEAD<cr>", "Diff" },
	},
	l = {
		name = "LSP",
		d = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "declaration" },
		i = { "<cmd>lua require'telescope.builtin'.lsp_implementations()<cr>", "implementions" },
		s = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "signature help" },
		S = { "<cmd>lua require'telescope.builtin'.lsp_document_symbols()<cr>", "symbols" },
		e = { "<cmd>lua require'telescope.builtin'.diagnostics()<cr>", "diagnostics" },
		l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
		q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
		R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
	},
	L = {
		name = "LSP config",
		f = { "<cmd>lua vim.lsp.buf.format{async=true}<cr>", "Format" },
		s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
		S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
	},
	s = {
		name = "Search",
		b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
		c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
		h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
		M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
		r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
		R = { "<cmd>Telescope registers<cr>", "Registers" },
		k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
		C = { "<cmd>Telescope commands<cr>", "Commands" },
	},
	t = {
		name = "Terminal",
		n = { "<cmd>lua _NODE_TOGGLE()<cr>", "Node" },
		f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
		h = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", "Horizontal" },
		v = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", "Vertical" },
	},
}

local opts = {
	mode = "n", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

which_key.setup({})
which_key.register(mappings, opts)
