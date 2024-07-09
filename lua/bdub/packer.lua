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
	use("mileszs/ack.vim") -- Ack search
	use("tpope/vim-dispatch") -- Async commands
	use("windwp/nvim-autopairs") -- Autopairs, integrates with both cmp and treesitter
	use("windwp/nvim-ts-autotag") -- auto close html tags
	use({
		"kevinhwang91/nvim-bqf", -- Better quickfix
		ft = "qf",
	})

	use({
		"utilyre/barbecue.nvim",
		tag = "*",
		requires = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons", -- optional dependency
		},
		after = "nvim-web-devicons", -- keep this if you're using NvChad
	})

	-- use({
	-- 	"laytan/tailwind-sorter.nvim",
	-- 	requires = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
	-- 	config = function()
	-- 		require("tailwind-sorter").setup()
	-- 	end,
	-- 	run = "cd formatter && npm ci && npm run build",
	-- })

	use({
		"kevinhwang91/nvim-hlslens", -- Better search
		config = function()
			require("hlslens").setup()
		end,
	})

	use({
		"cbochs/grapple.nvim", -- Bookmarks / tags
		requires = { "nvim-lua/plenary.nvim" },
		-- commit = "12172536620464f8cc124e07c6e3ccd306ea3c5c",
	})

	-- use({
	-- 	"romgrk/barbar.nvim",
	-- 	config = function()
	-- 		local barbar = require("barbar")
	-- 		barbar.setup({
	-- 			icons = {
	-- 				gitsigns = {
	-- 					added = { enabled = true, icon = "+" },
	-- 					changed = { enabled = true, icon = "~" },
	-- 					deleted = { enabled = true, icon = "-" },
	-- 				},
	-- 			},
	-- 		})
	-- 	end,
	-- }) -- Bufferline

	-- use({
	-- 	"theprimeagen/harpoon",
	-- 	branch = "harpoon2",
	-- 	config = function()
	-- 		require("harpoon"):setup()
	-- 	end,
	-- 	requires = { { "nvim-lua/plenary.nvim" } },
	-- }) -- Bookmarks
	use("tpope/vim-abolish") -- case conversion / substitution
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({
				pre_hook = function()
					return vim.bo.commentstring
				end,
			})
		end,
	})
	use({
		"JoosepAlviste/nvim-ts-context-commentstring", -- comments
		config = function()
			require("ts_context_commentstring").setup({})
		end,
	})
	use("github/copilot.vim") -- copilot

	-- use("tpope/vim-dadbod") -- db
	-- use({
	-- 	"kristijanhusak/vim-dadbod-ui", -- db
	-- 	config = function()
	-- 		vim.g.db_ui_auto_execute_table_helpers = 1
	-- 	end,
	-- })
	-- use("nvim-telescope/telescope-dap.nvim") -- Debugging
	-- use({
	--     "mfussenegger/nvim-dap", -- Debugging
	--     requires = {
	--         "ravenxrz/DAPInstall.nvim",
	--         "rcarriga/nvim-dap-ui",
	--     },
	-- })

	use("stevearc/oil.nvim") -- file explorer
	-- use({
	-- 	"nvim-neo-tree/neo-tree.nvim", -- file explorer
	-- 	requires = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
	-- 		"MunifTanjim/nui.nvim",
	-- 		"s1n7ax/nvim-window-picker",
	-- 	},
	-- })
	use({
		"stevearc/aerial.nvim", -- file outline
		requires = {
			"nvim-tree/nvim-web-devicons",
			"kyazdani42/nvim-web-devicons",
		},
	})

	use({
		"neanias/everforest-nvim",
		-- Optional; default configuration will be used if setup isn't called.
		config = function()
			require("everforest").setup()
		end,
	})

	use({
		"akinsho/git-conflict.nvim", -- Git conflict markers
		tag = "*",
	})
	use("tpope/vim-fugitive") -- Git
	use("f-person/git-blame.nvim") -- Git blame
	use("lewis6991/gitsigns.nvim") -- Git signs
	use("sindrets/diffview.nvim") -- Git diff
	use({
		"chentoast/marks.nvim",
		config = function()
			require("marks").setup()
		end,
	}) -- marks

	use("Pocco81/HighStr.nvim") -- Highlight strings
	-- use("RRethy/vim-illuminate") -- Highlight word under cursor
	use("kyazdani42/nvim-web-devicons") -- Icons

	use("neovim/nvim-lspconfig")
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")

	use("hrsh7th/cmp-nvim-lsp-signature-help")

	use("jose-elias-alvarez/null-ls.nvim")

	use({ "hrsh7th/nvim-cmp" })
	use({ "hrsh7th/cmp-nvim-lsp" })
	use({
		"hrsh7th/cmp-nvim-lua",
	})
	use({ "hrsh7th/cmp-buffer" })
	use({ "hrsh7th/cmp-path" })

	use({
		"pmizio/typescript-tools.nvim",
		branch = "bugfix/202",
		requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	})

	use("dnlhc/glance.nvim") -- LSP

	use("camilledejoye/nvim-lsp-selection-range") -- LSP
	use({
		"nvim-lua/lsp-status.nvim", -- LSP
		config = function()
			require("lsp-status").register_progress()
		end,
	})

	use({
		"AckslD/messages.nvim", -- messages
		config = function()
			require("messages").setup()
		end,
	})
	use("booperlv/nvim-gomove") -- move lines around
	-- use("abecodes/tabout.nvim") -- move cursor between brackets
	use({
		"kawre/neotab.nvim",
		config = function()
			require("neotab").setup({
				enable_persistant_history = true,
				auto_insert = true,
				act_as_tab = false,
				disable_default_keybindings = false,
				keys = {
					next = "<Tab>",
					prev = "<S-Tab>",
					close = "<C-c>",
					toggle = "<C-t>",
				},
			})
		end,
	})

	use({
		"rcarriga/nvim-notify",
		config = function()
			-- vim.notify = require("notify")
		end,
	})

	use({
		"folke/noice.nvim", -- nice notifications
		requires = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	})

	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }) -- Treesitter
	use("nvim-treesitter/nvim-treesitter-context") -- Treesitter
	use("RRethy/nvim-treesitter-textsubjects") -- Treesitter
	use("nvim-treesitter/nvim-treesitter-textobjects") -- Treesitter
	use("nvim-treesitter/playground") -- Treesitter

	use("sindrets/winshift.nvim") -- Move windows around
	use("rmagatti/goto-preview") -- Preview goto
	use("stevearc/dressing.nvim") -- UI niceties
	use("mbbill/undotree") -- Undo tree

	use("folke/which-key.nvim") -- Keybindings

	use("sbulav/nredir.nvim") -- Redirects output
	use("dstein64/vim-startuptime") -- startup time
	use({
		"nvim-lualine/lualine.nvim", -- statusline
		requires = {
			"kyazdani42/nvim-web-devicons",
		},
	})
	use("tpope/vim-surround") -- surround text with brackets
	use({
		"nvim-telescope/telescope.nvim", -- Telescope
		requires = { { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-live-grep-args.nvim" } },
	})
	use("nvim-telescope/telescope-live-grep-args.nvim") -- Telescope
	use("nvim-telescope/telescope-ui-select.nvim") -- Telescope
	use({
		"nvim-telescope/telescope-fzf-native.nvim", -- Telescope
		run = "make",
	})
	use("akinsho/toggleterm.nvim") -- Terminal

	-- use({
	-- 	"sainnhe/everforest", -- Theme
	-- 	as = "everforest",
	-- 	config = function()
	-- 		vim.g.everforest_background = "hard"
	-- 		vim.cmd("colorscheme everforest")
	-- 	end,
	-- })
	use({
		"dmmulroy/tsc.nvim", -- Typescript
		config = function()
			require("tsc").setup({
				use_diagnostics = true,
			})
		end,
	})

	use({
		"s1n7ax/nvim-window-picker", -- window picker
		config = function()
			require("window-picker").setup()
		end,
	})

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
