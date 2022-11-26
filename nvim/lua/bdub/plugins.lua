local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end
-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local packer_ok, packer = pcall(require, "packer")
if not packer_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  use { "wbthomason/packer.nvim" } -- Have packer manage itself
  use { "nvim-lua/plenary.nvim" } -- Useful lua functions used by lots of plugins
  use { "nvim-treesitter/nvim-treesitter" }
  use { "windwp/nvim-autopairs" } -- Autopairs, integrates with both cmp and treesitter
  use "szw/vim-maximizer"
  use "sindrets/diffview.nvim"

  use {
    "numToStr/Comment.nvim",
    "JoosepAlviste/nvim-ts-context-commentstring",
  }

  use "kyazdani42/nvim-web-devicons"
  use "kyazdani42/nvim-tree.lua"
  use "moll/vim-bbye"
  use "nvim-lualine/lualine.nvim"
  use "akinsho/toggleterm.nvim"
  use "lewis6991/impatient.nvim"
  use "lukas-reineke/indent-blankline.nvim"
  use "folke/which-key.nvim"
  use "booperlv/nvim-gomove"
  use "abecodes/tabout.nvim"
  use "ThePrimeagen/harpoon"
  use "mbbill/undotree"
  use "github/copilot.vim"
  use "tpope/vim-surround"

  use "f-person/git-blame.nvim"
  use "arkav/lualine-lsp-progress"

  use {
    "AckslD/nvim-neoclip.lua",
    requires = {
      -- you'll need at least one of these
      { "nvim-telescope/telescope.nvim" },
      -- {'ibhagwan/fzf-lua'},
    },
    config = function()
      require("neoclip").setup {}
    end,
  }
  -- Colorschemes
  use {
    "folke/tokyonight.nvim",
    "lunarvim/darkplus.nvim",
    "sainnhe/everforest",
  }

  -- Cmp
  use {
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
  }

  -- Snippets
  use {
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
  }

  -- LSP
  use {
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "jose-elias-alvarez/nvim-lsp-ts-utils",
    "williamboman/mason-lspconfig.nvim",
  }

  use { "jose-elias-alvarez/null-ls.nvim" } -- for formatters and linters
  use { "RRethy/vim-illuminate" }
  use "nvim-lua/popup.nvim"

  -- Telescope
  use {
    "nvim-telescope/telescope.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "make",
    },
  }

  -- Git
  use { "lewis6991/gitsigns.nvim" }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
