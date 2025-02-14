local colors = require("bdub.everforest_colors")

vim.cmd([[highlight HlSearchLens guibg=]] .. colors.bg4)

return {
  "kevinhwang91/nvim-hlslens",
  config = function()
    require("hlslens").setup({
      nearest_only = true,
    })
    require("hlslens").disable()
  end,
}
