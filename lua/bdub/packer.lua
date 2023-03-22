local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")

	vim.cmd([[packadd packer.nvim]])
end
-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function(use) -- Packer can manage itself use 'wbthomason/packer.nvim'
	use("wbthomason/packer.nvim")

	use({
		"sainnhe/everforest",
		as = "everforest",
		config = function()
			vim.g.everforest_background = "hard"
			vim.cmd("colorscheme everforest")
		end,
	})

	use("kyazdani42/nvim-web-devicons")
	use("stevearc/oil.nvim")
	use("tpope/vim-abolish")
	use("dstein64/vim-startuptime")

	use({
		"stevearc/aerial.nvim",
		config = function()
			require("aerial").setup()
		end,
	})

	use("ray-x/lsp_signature.nvim")

	use("camilledejoye/nvim-lsp-selection-range")
	use("RRethy/vim-illuminate")
	use("sbulav/nredir.nvim")
	use({
		"mfussenegger/nvim-dap",
		requires = {
			"ravenxrz/DAPInstall.nvim",
			"rcarriga/nvim-dap-ui",
		},
	})
	use("nvim-telescope/telescope-dap.nvim")
	use({ "stevearc/dressing.nvim" })

	use({ "TimUntersberger/neogit", requires = "nvim-lua/plenary.nvim" })
	use("akinsho/git-conflict.nvim")
	use({
		"AckslD/messages.nvim",
		config = 'require("messages").setup()',
	})

	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("nvim-treesitter/nvim-treesitter-context")
	use("RRethy/nvim-treesitter-textsubjects")
	use("nvim-treesitter/nvim-treesitter-textobjects")
	use("nvim-treesitter/playground")

	use("sindrets/winshift.nvim")
	use("rmagatti/goto-preview")

	use("tpope/vim-fugitive")
	use("f-person/git-blame.nvim")
	use("lewis6991/gitsigns.nvim")
	use("sindrets/diffview.nvim")

	use("akinsho/toggleterm.nvim")
	use("tpope/vim-dispatch")

	use("Pocco81/HighStr.nvim")

	use("theprimeagen/harpoon")

	use("mbbill/undotree")

	use("windwp/nvim-autopairs") -- Autopairs, integrates with both cmp and treesitter

	use("folke/which-key.nvim")
	use("folke/neodev.nvim")

	use("booperlv/nvim-gomove")
	use("abecodes/tabout.nvim")
	use("tpope/vim-surround")
	use("github/copilot.vim")
	use("windwp/nvim-ts-autotag")

	--- dad bod
	use("tpope/vim-dadbod")
	use({
		"kristijanhusak/vim-dadbod-ui",
		config = function()
			vim.g.db_ui_auto_execute_table_helpers = 1
		end,
	})
	--- end dad bod

	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		-- or                            , branch = '0.1.x',
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	use({ "nvim-telescope/telescope-ui-select.nvim" })
	use({
		"nvim-telescope/telescope-fzf-native.nvim",
		run = "make",
	})
	use({
		"nvim-lua/lsp-status.nvim",
		config = function()
			require("lsp-status").register_progress()
		end,
	})

	-- neotree:
	use({
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			"s1n7ax/nvim-window-picker",
		},
	})
	use({
		"s1n7ax/nvim-window-picker",
		tag = "v1.*",
		config = function()
			require("window-picker").setup()
		end,
	})
	-- neotree

	use({
		"nvim-lualine/lualine.nvim",
		requires = {
			"kyazdani42/nvim-web-devicons",
			"nvim-lua/lsp-status.nvim",
		},
	})

	use({
		"VonHeikemen/lsp-zero.nvim",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "hrsh7th/cmp-nvim-lsp-signature-help" },
			{ "jose-elias-alvarez/nvim-lsp-ts-utils" },
			{ "jose-elias-alvarez/null-ls.nvim" },

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },

			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
	})

	use({
		"numToStr/Comment.nvim",
		"JoosepAlviste/nvim-ts-context-commentstring",
	})

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
