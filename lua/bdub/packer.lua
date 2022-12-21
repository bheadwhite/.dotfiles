-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')
return require('packer').startup(function(use) -- Packer can manage itself use 'wbthomason/packer.nvim'

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.0',
    -- or                            , branch = '0.1.x',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }
  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make"
  }


  use({
    'sainnhe/everforest',
    as = 'everforest',
    config = function()
      vim.cmd('colorscheme everforest')
    end
  })

  use({ 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' })


  use('nvim-treesitter/playground')
  use('theprimeagen/harpoon')
  use('mbbill/undotree')

  use('tpope/vim-fugitive')

  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },

      -- Snippets
      { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },
    }
  }

  use("folke/zen-mode.nvim")
  use("github/copilot.vim")
  use "windwp/nvim-ts-autotag"
  use "sindrets/diffview.nvim"
  use "nvim-treesitter/nvim-treesitter-context"
  use "tpope/vim-dadbod"
  use {
    "kristijanhusak/vim-dadbod-ui",
    config = function()
      vim.g.db_ui_auto_execute_table_helpers = 1
    end,
  }
  use {
    "numToStr/Comment.nvim",
    "JoosepAlviste/nvim-ts-context-commentstring",
  }

  use "booperlv/nvim-gomove"
  use "abecodes/tabout.nvim"
  use "tpope/vim-surround"

end)
