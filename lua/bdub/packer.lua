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
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		-- or                            , branch = '0.1.x',
		requires = { { "nvim-lua/plenary.nvim" } },
	})
	use({
		"nvim-telescope/telescope-fzf-native.nvim",
		run = "make",
	})
	use({ "nvim-telescope/telescope-ui-select.nvim" })

	use({
		"sainnhe/everforest",
		as = "everforest",
		config = function()
			vim.cmd("colorscheme everforest")
		end,
	})
	use("RRethy/vim-illuminate")
	use({ "nvim-telescope/telescope-file-browser.nvim" })

	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("nvim-lualine/lualine.nvim")
	use("szw/vim-maximizer")

	use("nvim-treesitter/playground")
	use("theprimeagen/harpoon")
	use("mbbill/undotree")
	use("windwp/nvim-autopairs") -- Autopairs, integrates with both cmp and treesitter
	use("f-person/git-blame.nvim")
	use("kyazdani42/nvim-web-devicons")
	use("folke/which-key.nvim")

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

	use("folke/zen-mode.nvim")
	use("github/copilot.vim")
	use("windwp/nvim-ts-autotag")
	use("sindrets/diffview.nvim")
	use("nvim-treesitter/nvim-treesitter-context")
	use("tpope/vim-dadbod")
	use({
		"kristijanhusak/vim-dadbod-ui",
		config = function()
			vim.g.db_ui_auto_execute_table_helpers = 1
		end,
	})
	use({
		"numToStr/Comment.nvim",
		"JoosepAlviste/nvim-ts-context-commentstring",
	})

	use("booperlv/nvim-gomove")
	use("abecodes/tabout.nvim")
	use("tpope/vim-surround")
	use("lewis6991/gitsigns.nvim")
	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
