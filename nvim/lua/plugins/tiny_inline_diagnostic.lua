-- return {}
if vim.version().minor < 10 then
  return {}
end

return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        options = {
          show_source = {
            enabled = true,
          },
        },
      })
      vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
      require("tiny-inline-diagnostic").disable()
    end,
  },

  -- {
  --   "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  --   config = function()
  --     require("lsp_lines").setup()
  --     vim.keymap.set("", "<leader>l", function()
  --       require("lsp_lines").toggle()
  --     end, { noremap = true })
  --   end,
  -- },
}
