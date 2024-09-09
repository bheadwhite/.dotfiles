return {
  { "mileszs/ack.vim" }, -- Integrates 'ack' search tool
  { "windwp/nvim-ts-autotag" }, -- Auto-closes HTML tags
  { "stevearc/dressing.nvim" }, -- Improved UI components
  { "sbulav/nredir.nvim" }, -- Redirects command output
  { "dstein64/vim-startuptime" }, -- startup time
  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter-context",
    "RRethy/nvim-treesitter-textsubjects",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/playground",
  },
  {
    "andymass/vim-matchup",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  {
    "olimorris/persisted.nvim",
    lazy = false,
    config = function()
      require("persisted").setup({
        autoload = true,
      })
    end,
  },
  -- {
  --   "rmagatti/auto-session",
  --   lazy = false,
  --   dependencies = {
  --     "nvim-telescope/telescope.nvim", -- Only needed if you want to use sesssion lens
  --   },
  --   config = function()
  --     require("auto-session").setup({
  --       silent_restore = true,
  --       cwd_change_handling = {
  --         restore_upcoming_session = true,
  --         post_cwd_changed_hook = function()
  --           require("lualine").refresh()
  --         end,
  --       },
  --     })
  --     -- vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
  --   end,
  -- },
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
    "troydm/zoomwintab.vim",
    config = function()
      vim.g.zoomwintab = 1
    end,
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
      run_as_monorepo = true,
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
  { "echasnovski/mini.splitjoin", version = false, config = true },
  {
    "bheadwhite/vim-bookmarks",
    init = function()
      vim.g.bookmark_annotation_sign = "🔖"
    end,
    config = function()
      vim.keymap.set({ "n", "x" }, "<C-M-p>", function()
        require("bdub.bookmarks").telescope_bookmarks({})
      end)

      vim.keymap.set({ "n", "x" }, "<C-M-.>", function()
        vim.cmd("BookmarkNext")
      end)

      vim.keymap.set({ "n", "x" }, "<C-M-,>", function()
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
    "bloznelis/before.nvim",
    config = function()
      local before = require("before")
      before.setup()

      -- Jump to previous entry in the edit history
      vim.keymap.set("n", "<c-s-h>", before.jump_to_last_edit, {})

      -- Jump to next entry in the edit history
      vim.keymap.set("n", "<c-s-l>", before.jump_to_next_edit, {})

      -- -- Look for previous edits in quickfix list
      -- vim.keymap.set("n", "<leader>oq", before.show_edits_in_quickfix, {})
      --
      -- -- Look for previous edits in telescope (needs telescope, obviously)
      -- vim.keymap.set("n", "<leader>oe", before.show_edits_in_telescope, {})
    end,
  },
  {
    "nvim-lua/lsp-status.nvim", -- LSP
    config = function()
      require("lsp-status").register_progress()
    end,
  },
  { "AckslD/messages.nvim", config = true }, -- messages
  -- tailwind-tools.lua
  {
    "luckasRanarison/tailwind-tools.nvim",
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- optional
      "neovim/nvim-lspconfig", -- optional
    },
    config = function()
      require("tailwind-tools").setup()

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.css,*.scss,*.sass,*.less,*.styl,*.html,*.js,*.ts,*.jsx,*.tsx,*.vue",
        callback = function()
          vim.cmd("TailwindSortSync")
        end,
      })
    end,
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
