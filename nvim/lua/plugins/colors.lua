-- vim.g.everforest_transparent_background = 1
local colors = require("bdub.color_config")

return {
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
  {
    "rjshkhr/shadow.nvim",
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      vim.cmd.colorscheme("shadow")
      require("bdub.color_my_pencils")()

      --     vim.cmd([[highlight WinSeparator guifg=]] .. colors.winseperator)
      --     vim.cmd([[highlight CursorLine guibg=]] .. colors.cursorLine)
      --     vim.cmd([[highlight Cursor guibg=]] .. colors.cursor)
      --     vim.cmd([[highlight Search guibg=]] .. colors.search .. [[ guifg=#000000]])
      --     vim.cmd([[highlight IncSearch guibg=]] .. colors.headerBg .. [[ guifg=#ffffff]])
      --     vim.cmd([[highlight CurSearch guibg=]] .. colors.search .. [[ guifg=#ffffff]])
      --     vim.cmd([[highlight GitSignsCurrentLineBlame guifg=]] .. colors.lineBlame)
      --     vim.cmd([[hi HlSearchLensNear guibg=#bac2de]] .. [[ guifg=]] .. colors.diffBg)
    end,
  },

  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   config = function()
  -- vim.cmd("colorscheme catppuccin-macchiato")
  -- vim.cmd([[highlight WinSeparator guifg=]] .. colors.winseperator)
  -- vim.cmd([[highlight CursorLine guibg=]] .. colors.cursorLine)
  -- vim.cmd([[highlight Cursor guibg=]] .. colors.cursor)
  -- vim.cmd([[highlight Search guibg=]] .. colors.search .. [[ guifg=#000000]])
  -- vim.cmd([[highlight IncSearch guibg=]] .. colors.headerBg .. [[ guifg=#ffffff]])
  -- vim.cmd([[highlight CurSearch guibg=]] .. colors.search .. [[ guifg=#ffffff]])
  -- vim.cmd([[highlight GitSignsCurrentLineBlame guifg=]] .. colors.lineBlame)
  -- vim.cmd([[hi HlSearchLensNear guibg=#bac2de]] .. [[ guifg=]] .. colors.diffBg)
  --   end,
  -- },
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
