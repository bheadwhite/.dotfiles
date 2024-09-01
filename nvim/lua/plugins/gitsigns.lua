return {
  "lewis6991/gitsigns.nvim",
  config = function()
    local gitsigns = require("gitsigns")
    gitsigns.setup({
      attach_to_untracked = true,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 3000,
      },

      signs = {
        delete = {
          text = "",
        },
        topdelete = {
          text = "",
        },
      },
      sign_priority = 10,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000,
      preview_config = {
        -- Options passed to nvim_open_win
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
    })

    -- blame = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
    -- reset_hunk = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
    -- reset_buffer = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
    -- stage_hunk = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
    -- preview_hunk = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "preview hunk" },
    -- undo_stage_hunk = { "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", "Undo Stage Hunk" },
    -- diff = { "<cmd>Gitsigns diffthis HEAD<cr>", "Diff" },

    local last_func = nil
    -- use last command function
    local function use_last_func()
      if last_func then
        last_func()
      end
    end

    function function_decorator(func)
      return function()
        last_func = func
        func()
      end
    end

    local nextHunk = function_decorator(function()
      local current_line_nr = vim.fn.line(".")
      require("gitsigns").next_hunk()
      local did_change = vim.fn.line(".") ~= current_line_nr
      if did_change then
        vim.cmd([[normal! zz]])
      end
    end)

    local prevHunk = function_decorator(function()
      local current_line_nr = vim.fn.line(".")
      require("gitsigns").prev_hunk()
      if vim.fn.line(".") ~= current_line_nr then
        vim.cmd([[normal! zz]])
      end
    end)

    vim.keymap.set("n", "<C-M-Enter>", use_last_func, { noremap = true, silent = true, desc = "use last func" })

    -- Key mappings to invoke the commands
    vim.keymap.set("n", "<C-M-]>", nextHunk, { noremap = true, silent = true, desc = "next hunk" })
    vim.keymap.set("n", "<C-M-[>", prevHunk, { noremap = true, silent = true, desc = "prev hunk" })
    vim.keymap.set("n", "<leader>gb", "<cmd>lua require 'gitsigns'.blame_line()<cr>", { desc = "blame line" })
    vim.keymap.set("n", "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", { desc = "reset hunk" })
    vim.keymap.set("n", "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", { desc = "reset buffer" })
    vim.keymap.set("n", "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", { desc = "preview hunk" })
    vim.keymap.set("n", "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", { desc = "stage hunk" })
  end,
}
