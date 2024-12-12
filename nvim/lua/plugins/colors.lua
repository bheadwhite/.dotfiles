local colors = require("bdub.color_config")
-- vim.g.everforest_transparent_background = 1

return {
  -- {
  --   "norcalli/nvim-colorizer.lua",
  --   config = function()
  --     require("colorizer").setup()
  --   end,
  -- },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, opts = {
    flavour = "Mocha",
  } },
  {
    "neanias/everforest-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      function ColorMyPencils(color)
        color = color or "everforest"
        vim.cmd.colorscheme(color)
      end

      ColorMyPencils("catppuccin")

      vim.cmd([[highlight WinSeparator guifg=]] .. "#000000")
    end,
  },
}
