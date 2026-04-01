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
        ensure_installed = { "lua", "typescript", "javascript", "tsx", "html", "css", "json", "yaml", "go" },
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
}
