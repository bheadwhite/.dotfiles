local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end


return require('packer').startup(function(use)

  -- lsp
  use {"neovim/nvim-lspconfig"}
  use {"nvim-lua/lsp-status.nvim"}
  use {"tjdevries/lsp_extensions.nvim"}
  use {"onsails/lspkind-nvim"}
  use {"ray-x/lsp_signature.nvim"}
  use {"hrsh7th/cmp-nvim-lsp"}
  use {"hrsh7th/cmp-buffer"}
  use {
    "hrsh7th/nvim-cmp",
    config = function()
      require('config.nvim-cmp')
    end
  }
  use {"williamboman/nvim-lsp-installer"}
  use {"fsouza/prettierd"}
  use {"tami5/lspsaga.nvim"}

  -- tree sitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ':TSUpdate',
    config = function()
      require('config/nvim-treesitter')
    end
  }
  use {"nvim-treesitter/playground"}
  use {"nvim-treesitter/nvim-treesitter-textobjects"}

  -- snippets
  use {"L3MON4D3/LuaSnip"}
  use {"rafamadriz/friendly-snippets"}

  -- tpope!
  use {"tpope/vim-commentary"}
  use {"tpope/vim-fugitive"}
  use {"tpope/vim-rhubarb"}
  use {"tpope/vim-surround"}
  use {"tpope/vim-dispatch"}
  use {"tpope/vim-projectionist"}

  -- file tree
  use {
    "kyazdani42/nvim-web-devicons",
    config = function()
      require('config.nvim-web-devicons')
    end
  }
  use {
    "kyazdani42/nvim-tree.lua",
    config = function()
      require("config.nvim-tree")
    end
  }

  -- telescope
  use {
    "nvim-telescope/telescope.nvim",
    config = function()
      require('config.telescope')
    end
  }
  use {"nvim-telescope/telescope-fzy-native.nvim"}
  use {"nvim-lua/popup.nvim"}
  use {"nvim-lua/plenary.nvim"}

  -- misc
  use {"mbbill/undotree"}
  use {"ThePrimeagen/harpoon"}
  use {
    "airblade/vim-gitgutter",
    config = function()
      require('config.git-gutter')
    end
  }
  use {"airblade/vim-rooter"}
  use {"jiangmiao/auto-pairs"}
  use {"lazytanuki/nvim-mapper"}
  use {"hoob3rt/lualine.nvim"}
  use {"justinmk/vim-sneak"}
  use {"simrat39/symbols-outline.nvim"}
  use {"ThePrimeagen/git-worktree.nvim"}
  use {"vim-utils/vim-man"}
  use {"junegunn/gv.vim"}
  use {"tomlion/vim-solidity"}

  -- themes
  use {"gruvbox-community/gruvbox"}
  use {"sainnhe/gruvbox-material"}

  if packer_bootstrap then
    require('packer').sync()
  end
end)

