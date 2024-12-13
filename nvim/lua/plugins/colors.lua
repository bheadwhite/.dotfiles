-- vim.g.everforest_transparent_background = 1

return {
  -- {
  --   "norcalli/nvim-colorizer.lua",
  --   config = function()
  --     require("colorizer").setup()
  --   end,
  -- },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme catppuccin-macchiato")
      vim.cmd([[highlight WinSeparator guifg=]] .. "#000000")
      vim.cmd([[highlight CursorLine guibg=#653A45]])
      vim.cmd([[highlight Cursor guibg=#FFFFFF]])
      vim.cmd([[highlight GitSignsCurrentLineBlame guifg=#FFFFFF]])
    end,
  },
  -- {
  --   "rose-pine/neovim",
  --   name = "rose-pine",
  --   config = function()
  --     require("rose-pine").setup({
  --       variant = "moon",
  --     })
  --     vim.cmd("colorscheme rose-pine")
  --   end,
  -- },
  -- {
  --   "neanias/everforest-nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     function ColorMyPencils(color)
  --       color = color or "everforest"
  --       vim.cmd.colorscheme(color)
  --     end
  --
  --     ColorMyPencils()
  --   end,
  -- },
}
