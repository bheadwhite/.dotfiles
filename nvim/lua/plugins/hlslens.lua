local colors = require("bdub.everforest_colors")

vim.cmd([[highlight HlSearchLens guibg=]] .. colors.bg4)

return {
  "kevinhwang91/nvim-hlslens",
  opts = {
    nearest_only = true,
  },
}
