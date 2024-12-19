local colors = require("bdub.color_config")
return {
  "Pocco81/HighStr.nvim",
  config = function()
    require("high-str").setup({
      saving_path = "/tmp/highstr/",
      highlight_colors = { -- everforest highlight colors
        color_0 = { colors.cursorLine, "smart" }, -- blue
        color_1 = { "#3C4841", "smart" }, -- green
        color_2 = { "#45443C", "smart" }, -- yellow
        color_3 = { "#493B40", "smart" }, -- bg_visual
        color_4 = { "#4C3743", "smart" }, -- bg_red
      },
    })

    vim.keymap.set("v", "<leader>hh", ":<c-u>HSHighlight 0<cr>", { noremap = true, silent = true })
    vim.keymap.set("v", "<leader>hj", ":<c-u>HSHighlight 1<cr>", { noremap = true, silent = true })
    vim.keymap.set("v", "<leader>hk", ":<c-u>HSHighlight 2<cr>", { noremap = true, silent = true })
    vim.keymap.set("v", "<leader>hl", ":<c-u>HSHighlight 3<cr>", { noremap = true, silent = true })
    vim.keymap.set("v", "<leader>h;", ":<c-u>HSHighlight 4<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>hh", ":<c-u>HSRmHighlight rm_all<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>Hh", ":<c-u>HSRmHighlight 0<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>Hj", ":<c-u>HSRmHighlight 1<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>Hk", ":<c-u>HSRmHighlight 2<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>Hl", ":<c-u>HSRmHighlight 3<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>H;", ":<c-u>HSRmHighlight 4<cr>", { noremap = true, silent = true })
  end,
}
