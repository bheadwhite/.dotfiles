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
  {
    "rmagatti/auto-session",
    lazy = false,
    dependencies = {
      "nvim-telescope/telescope.nvim", -- Only needed if you want to use sesssion lens
    },
    config = function()
      require("auto-session").setup({
        silent_restore = false,
        cwd_change_handling = {
          restore_upcoming_session = true,
          post_cwd_changed_hook = function()
            require("lualine").refresh()
          end,
        },
      })
      vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end,
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
  { "nanotee/zoxide.vim" },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = { "zbirenbaum/copilot.vim", "nvim-lua/plenary.nvim" },
    config = function()
      require("CopilotChat").setup()
    end,
  },
  {
    "dmmulroy/tsc.nvim", -- Typescript
    opts = {
      use_diagnostics = true,
    },
  },
  { "s1n7ax/nvim-window-picker" }, -- window picker
  {
    "nvim-telescope/telescope-fzf-native.nvim", -- Telescope
    build = "make",
  },
  { "nvim-telescope/telescope-live-grep-args.nvim" },
  { "nvim-telescope/telescope-ui-select.nvim" },
  { "echasnovski/mini.nvim" }, -- mini. using for zooming in and out of windows
  {
    "bheadwhite/vim-bookmarks",
    init = function()
      vim.g.bookmark_annotation_sign = "🔖"
    end,
    config = function()
      vim.keymap.set({ "n", "x" }, "<C-M-p>", function()
        require("bdub.bookmarks").telescope_bookmarks({})
      end)

      vim.keymap.set({ "n", "x" }, "<C-M-]>", function()
        vim.cmd("BookmarkNext")
      end)

      vim.keymap.set({ "n", "x" }, "<C-M-[>", function()
        vim.cmd("BookmarkPrev")
      end)
    end,
  },
  {
    "echasnovski/mini.files",
    version = false,
    config = function()
      local mini_files = require("mini.files")
      mini_files.setup({
        mappings = {
          go_in = "",
          go_out = "",
        },
        windows = {
          preview = false,
        },
      })

      require("bdub.mini_files").setup()
    end,
  },
  { "tpope/vim-abolish", "tpope/vim-surround" },
  { "tpope/vim-dispatch", event = "VeryLazy" },
  { "nvim-zh/better-escape.vim", event = "InsertEnter" }, -- better escape from insert mode
  { "JoosepAlviste/nvim-ts-context-commentstring" }, -- comments
  { "williamboman/mason.nvim", "camilledejoye/nvim-lsp-selection-range" },
  {
    "nvim-lua/lsp-status.nvim", -- LSP
    config = function()
      require("lsp-status").register_progress()
    end,
  },
  { "AckslD/messages.nvim", config = true }, -- messages
  -- {
  -- 	"numToStr/Comment.nvim",
  -- 	opts = {
  -- 		pre_hook = function()
  -- 			return vim.bo.commentstring
  -- 		end,
  -- 	},
  -- },
}
