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
        },
        highlight = {
          enable = true,
        },
      })
      vim.keymap.set("n", "<C-M-O>", function()
        require("treesitter-modules").init_selection()
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
