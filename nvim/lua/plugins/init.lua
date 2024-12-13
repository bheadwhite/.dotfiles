local colors = require("bdub.catppuccin_colors")
return {
  { "mileszs/ack.vim" }, -- Integrates 'ack' search tool
  { "windwp/nvim-ts-autotag" }, -- Auto-closes HTML tags
  { "stevearc/dressing.nvim" }, -- Improved UI components
  { "sbulav/nredir.nvim" }, -- Redirects command output
  { "dstein64/vim-startuptime" }, -- startup time
  -- treesitter
  {
    -- "nvim-treesitter/nvim-treesitter-context",
    "RRethy/nvim-treesitter-textsubjects",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/playground",
  },
  -- {
  --   "andymass/vim-matchup",
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   config = function()
  --     vim.g.matchup_matchparen_offscreen = { method = "popup" }
  --   end,
  -- },
  {
    "nvim-zh/colorful-winsep.nvim",
    config = function()
      require("colorful-winsep").setup()
      vim.cmd([[highlight NvimSeparator guifg=]] .. colors.mocha.overlay0)
    end,
    event = { "WinLeave" },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  {
    "mxsdev/nvim-dap-vscode-js",
    lazy = false,
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local home = os.getenv("HOME")
      require("dap-vscode-js").setup({
        adapters = { "pwa-chrome" },
        debugger_path = home .. "/code/vscode-js-debug",
      })
    end,
  },
  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },
  { "yochem/jq-playground.nvim", opts = {
    query_window = {
      height = 0.2,
    },
  } },
  -- {
  --   "rachartier/tiny-inline-diagnostic.nvim",
  --   opts = {
  --     options = {
  --       show_source = true,
  --     },
  --   },
  -- },
  {
    "max397574/colortils.nvim",
    cmd = "Colortils",
    config = function()
      require("colortils").setup()
    end,
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
    branch = "main",
    build = "make tiktoken", -- Only on MacOS or Linux
    dependencies = { "zbirenbaum/copilot.vim", "nvim-lua/plenary.nvim" },
    config = function()
      require("CopilotChat").setup()
    end,
  },
  {
    "folke/trouble.nvim",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
    opts = {},
  },
  {
    "dmmulroy/tsc.nvim", -- Typescript
    opts = {
      use_diagnostics = true,
      -- run_as_monorepo = true,

      -- if TSC runs and your expecting results but there arent any..
      -- it could be that your getting the "this is not the TSC your looking for" error when running TSC
      -- find the path to the tsc bin by running require("tsc.utils").get_tsc_bin()
      -- troubleshoot why thats not running as a standalone
      -- references:
      -- https://stackoverflow.com/questions/69080861/error-running-a-npx-tsc-command-regarding-typescript-this-is-not-the-tsc-comm
    },
  },
  { "s1n7ax/nvim-window-picker" }, -- window picker
  {
    "nvim-telescope/telescope-fzf-native.nvim", -- Telescope
    build = "make",
  },
  {
    "nvim-telescope/telescope-dap.nvim",
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
  -- {
  -- 	"numToStr/Comment.nvim",
  -- 	opts = {
  -- 		pre_hook = function()
  -- 			return vim.bo.commentstring
  -- 		end,
  -- 	},
  -- },
}
