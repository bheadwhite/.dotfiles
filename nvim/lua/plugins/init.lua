local function getColors()
  return require("bdub.catppuccin_colors")
end

return {
  { "mileszs/ack.vim" }, -- Integrates 'ack' search tool
  {
    "windwp/nvim-ts-autotag",
    config = {
      opts = {
        enable_close = true,
        enable_rename = false,
        enable_close_on_slash = true
      }
    },
  }, -- Auto-closes HTML tags
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
      if vim.g.vscode then
        return
      end
      require("colorful-winsep").setup()
      vim.cmd([[highlight NvimSeparator guifg=]] .. getColors().mocha.overlay0)
    end,
    event = { "WinLeave" },
  },
  {
    "RRethy/vim-illuminate",
    config = function()
      if vim.g.vscode then
        return
      end
      require("illuminate").configure({
        providers = {
          "lsp",
        },
      })
      vim.cmd([[hi IlluminatedWordText guifg=#FFC83D guibg=#2A2F33 gui=bold,underline guisp=#FFB000]])
      vim.cmd([[hi IlluminatedWordRead guifg=#FFC83D guibg=#2A2F33 gui=bold,underline guisp=#FFB000]])
      vim.cmd([[hi IlluminatedWordWrite guifg=#FFC83D guibg=#2A2F33 gui=bold,underline guisp=#FFB000]])
    end,
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
  -- Disabled nvim-cmp sources (using native LSP completion instead)
  -- {
  --   "hrsh7th/cmp-nvim-lsp-signature-help",
  --   "hrsh7th/cmp-nvim-lsp",
  --   "hrsh7th/cmp-nvim-lua",
  --   "hrsh7th/cmp-buffer",
  --   "hrsh7th/cmp-path",
  -- },
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
      if vim.g.vscode then
        return
      end
      local mc = require("multicursor-nvim")
      mc.setup()
    end,
  },
  -- { "yochem/jq-playground.nvim", opts = {
  --   query_window = {
  --     height = 0.2,
  --   },
  -- } },
  {
    "max397574/colortils.nvim",
    cmd = "Colortils",
    config = function()
      if vim.g.vscode then
        return
      end
      require("colortils").setup()
    end,
  },
  -- {
  --   "anuvyklack/windows.nvim",
  --   dependencies = { "anuvyklack/middleclass" },
  --   config = function()
  --     require("windows").setup()
  --   end,
  -- },
  -- {
  --   "fasterius/simple-zoom.nvim",
  --   config = true,
  -- },
  -- { "nanotee/zoxide.vim" },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    build = "make tiktoken", -- Only on MacOS or Linux
    dependencies = { "zbirenbaum/copilot.lua", "nvim-lua/plenary.nvim" },
    config = function()
      require("CopilotChat").setup()
    end,
  },
  -- {
  --   "folke/trouble.nvim",
  --   keys = {
  --     {
  --       "<leader>xx",
  --       "<cmd>Trouble diagnostics toggle<cr>",
  --       desc = "Diagnostics (Trouble)",
  --     },
  --     {
  --       "<leader>xX",
  --       "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
  --       desc = "Buffer Diagnostics (Trouble)",
  --     },
  --     {
  --       "<leader>cs",
  --       "<cmd>Trouble symbols toggle focus=false<cr>",
  --       desc = "Symbols (Trouble)",
  --     },
  --     {
  --       "<leader>cl",
  --       "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
  --       desc = "LSP Definitions / references / ... (Trouble)",
  --     },
  --     {
  --       "<leader>xL",
  --       "<cmd>Trouble loclist toggle<cr>",
  --       desc = "Location List (Trouble)",
  --     },
  --     {
  --       "<leader>xQ",
  --       "<cmd>Trouble qflist toggle<cr>",
  --       desc = "Quickfix List (Trouble)",
  --     },
  --   },
  --   opts = {},
  -- },
  -- {
  --   "tanvirtin/vgit.nvim",
  --   branch = "v1.0.x",
  --   -- or               , tag = 'v1.0.2',
  --   dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
  --   -- Lazy loading on 'VimEnter' event is necessary.
  --   event = "VimEnter",
  --   config = function()
  --     require("vgit").setup({
  --       settings = {
  --         live_gutter = {
  --           enabled = false,
  --         },
  --         live_blame = {
  --           enabled = false,
  --         },
  --         signs = {
  --           enabled = false,
  --         },
  --       },
  --     })
  --   end,
  --
  --   vim.keymap.set("n", "<esc>", function()
  --     print("hello world")
  --     -- <cmd>noh<cr><esc>
  --   end),
  -- },
  {
    "dmmulroy/tsc.nvim", -- Typescript
    opts = {
      -- use_diagnostics = true,
      -- run_as_monorepo = true,

      -- if TSC runs and your expecting results but there arent any..
      -- it could be that your getting the "this is not the TSC your looking for" error when running TSC
      -- find the path to the tsc bin by running require("tsc.utils").find_tsc_bin()
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
  -- {
  --   "bheadwhite/vim-bookmarks",
  --   init = function()
  --     vim.g.bookmark_annotation_sign = "🔖"
  --   end,
  --   config = function()
  --     vim.keymap.set({ "n", "x" }, "<C-M-p>", function()
  --       require("bdub.bookmarks").telescope_bookmarks({})
  --     end)
  --
  --     vim.keymap.set({ "n", "x" }, "<C-M-.>", function()
  --       vim.cmd("BookmarkNext")
  --     end)
  --
  --     vim.keymap.set({ "n", "x" }, "<C-M-,>", function()
  --       vim.cmd("BookmarkPrev")
  --     end)
  --   end,
  -- },
  { "tpope/vim-abolish", "tpope/vim-surround" },
  { "tpope/vim-dispatch", event = "VeryLazy" },
  { "nvim-zh/better-escape.vim", event = "InsertEnter" }, -- better escape from insert mode
  { "JoosepAlviste/nvim-ts-context-commentstring" }, -- comments
  { "camilledejoye/nvim-lsp-selection-range" },
  {
    "bloznelis/before.nvim",
    config = function()
      local before = require("before")
      if vim.g.vscode then
        return
      end
      before.setup()

      -- Jump to previous entry in the edit history
      vim.keymap.set("n", "<c-s-h>", before.jump_to_last_edit, {})

      -- Jump to next entry in the edit history
      vim.keymap.set("n", "<c-s-l>", before.jump_to_next_edit, {})
    end,
  },
  {
    "nvim-lua/lsp-status.nvim", -- LSP
    config = function()
      if vim.g.vscode then
        return
      end
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
