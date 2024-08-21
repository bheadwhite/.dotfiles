return {
  "utilyre/barbecue.nvim", -- uses navic - vscode like bookmarks in the winbar
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local barbecue = require("barbecue")
    barbecue.setup({
      show_navic = true,
      show_modified = true,
      show_dirname = false,
      theme = {
        basename = {
          fg = "#ffffff",
          bold = true,
        },
      },
      custom_section = function()
        return vim.fn.expand("%:.:h") .. "/"
      end,
    })
  end,
}
