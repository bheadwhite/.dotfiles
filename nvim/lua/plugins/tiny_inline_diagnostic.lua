if vim.version().minor < 10 then
  return {}
end

return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {
      options = {
        show_source = true,
        virt_texts = {
          priority = 9999,
        },
      },
    },
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
