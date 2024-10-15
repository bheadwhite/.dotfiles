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
  -- {
  --   "andymass/vim-matchup",
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   config = function()
  --     vim.g.matchup_matchparen_offscreen = { method = "popup" }
  --   end,
  -- },
  {
    "olimorris/persisted.nvim",
    lazy = false,
    config = function()
      require("persisted").setup({
        autoload = true,
      })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    lazy = false,
    config = function()
      require("dap").adapters.chrome = {
        type = "executable",
        command = "node",
      }

      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        require("dap").configurations[language] = {
          -- launch
          -- {
          --   type = "pwa-chrome",
          --   request = "launch",
          --   name = "Launch Chrome",
          --   url = "http://localhost:3000",
          --   webRoot = "${workspaceFolder}",
          -- },
          {
            type = "pwa-chrome",
            request = "attach",
            name = "Attach Chrome",
            port = 9222,
            webRoot = "${workspaceFolder}",
            runtimeExecutable = "canary",
          },
        }
      end

      vim.keymap.set("n", "<leader>dd", "<cmd>lua require('dap').continue()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>dc", "<cmd>lua require('dap').run_to_cursor()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>dr", "<cmd>lua require('dap').repl.toggle()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<C-M-S-.>", "<cmd>lua require('dap').step_over()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<C-M-S-i>", "<cmd>lua require('dap').step_into()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<C-M-S-,>", "<cmd>lua require('dap').step_out()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<C-M-S-h>", "<cmd>lua require('dap.ui.widgets').hover()<cr>", { noremap = true, silent = true })
      vim.keymap.set(
        "n",
        "<leader>df",
        "<cmd>lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').frames)<cr>",
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        "n",
        "<leader>ds",
        "<cmd>lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').scopes)<cr>",
        { noremap = true, silent = true }
      )
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
  -- {
  --   "rachartier/tiny-inline-diagnostic.nvim",
  --   opts = {
  --     options = {
  --       show_source = true,
  --     },
  --   },
  -- },
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

      local function file_exists(name)
        local f = io.open(name, "r")
        if f ~= nil then
          io.close(f)
          return true
        else
          return false
        end
      end

      -- Get the current working directory
      local cwd = vim.loop.cwd()

      -- only add this if we have a tailwind.config.js file in the root of the project
      if file_exists(cwd .. "/tailwind.config.js") then
        -- print("yes")
        vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = "*.css,*.scss,*.sass,*.less,*.styl,*.html,*.js,*.ts,*.jsx,*.tsx,*.vue",
          callback = function()
            vim.cmd("TailwindSortSync")
          end,
        })
      else
        -- print("no")
      end
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
