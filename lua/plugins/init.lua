return {
	{ "mileszs/ack.vim" },
	{ "windwp/nvim-ts-autotag" },
	{ "stevearc/dressing.nvim" }, -- UI niceties
	{ "sbulav/nredir.nvim" }, -- Redirects output
	{ "dstein64/vim-startuptime" }, -- startup time
	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter-context",
		"RRethy/nvim-treesitter-textsubjects",
		"nvim-treesitter/nvim-treesitter-textobjects",
		"nvim-treesitter/playground",
	},
	--cmp
	{
		"hrsh7th/cmp-nvim-lsp-signature-help",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
	},
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		opts = {
			options = {
				show_source = true,
			},
		},
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			"github/copilot.vim",
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"dmmulroy/tsc.nvim", -- Typescript
		opts = {
			use_diagnostics = true,
		},
	},
	{
		"s1n7ax/nvim-window-picker", -- window picker
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim", -- Telescope
		build = "make",
	},
	{ "nvim-telescope/telescope-live-grep-args.nvim" },
	{ "nvim-telescope/telescope-ui-select.nvim" },
	{
		"echasnovski/mini.nvim", -- mini. using for zooming in and out of windows
	},
	{ "sindrets/diffview.nvim" },
	{ "tpope/vim-abolish", "tpope/vim-surround" },
	{
		"tpope/vim-dispatch",
		event = "VeryLazy",
	},
	{ "nvim-zh/better-escape.vim", event = "InsertEnter" }, -- better escape from insert mode
	{
		"chentoast/marks.nvim",
		config = true,
	},
	{
		"JoosepAlviste/nvim-ts-context-commentstring", -- comments
	},
	{ "williamboman/mason.nvim", "camilledejoye/nvim-lsp-selection-range" },
	{
		"nvim-lua/lsp-status.nvim", -- LSP
		config = function()
			require("lsp-status").register_progress()
		end,
	},
	{
		"AckslD/messages.nvim", -- messages
		config = true,
	},
	-- {
	-- 	"numToStr/Comment.nvim",
	-- 	opts = {
	-- 		pre_hook = function()
	-- 			return vim.bo.commentstring
	-- 		end,
	-- 	},
	-- },
}
