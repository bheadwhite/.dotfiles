local treesitter_main = {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
}

if vim.version().minor < 10 then
  treesitter_main.tag = "v0.9.3"
end

return {
  treesitter_main,
  {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false, -- Load with treesitter (not lazy)
    config = function()
      require("treesitter-modules").setup({
        ensure_installed = { "lua", "typescript", "javascript", "tsx", "html", "css", "json", "yaml", "go", "svelte" },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = false,
          },
        },
        highlight = {
          enable = true,
        },
      })
      vim.keymap.set("n", "<C-M-O>", function()
        if vim.api.nvim_buf_line_count(0) > 0 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] ~= "" then
          require("treesitter-modules").init_selection()
        end
      end)

      vim.keymap.set("x", "<C-M-O>", function()
        require("treesitter-modules").node_incremental()
      end)
      vim.keymap.set("x", "<C-M-i>", function()
        require("treesitter-modules").node_decremental()
      end)

    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("treesitter-context").setup({
        max_lines = 8, -- cap total sticky context height (leave room for multi-line headers)
        multiline_threshold = 20, -- show full multi-line headers (e.g. method chains like ctl.ForPath(...).Exec(...))
        trim_scope = "outer", -- when over max_lines, drop the outermost scopes first
        mode = "cursor", -- context reflects where the cursor is, not just the topline
      })
      -- Jump up to the context header of the current scope
      vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { silent = true, desc = "Jump to context" })
      -- Toggle the sticky context line
      vim.keymap.set("n", "<leader>tc", "<cmd>TSContextToggle<CR>", { silent = true, desc = "Toggle TS context" })
    end,
  },
}
