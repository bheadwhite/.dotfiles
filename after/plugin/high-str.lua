require("high-str").setup({
	saving_path = "/tmp/highstr/",
	highlight_colors = { -- everforest highlight colors
		color_0 = { "#384B55", "smart" }, -- blue
		color_1 = { "#3C4841", "smart" }, -- green
		color_2 = { "#45443C", "smart" }, -- yellow
		color_3 = { "#493B40", "smart" }, -- bg_visual
		color_4 = { "#4C3743", "smart" }, -- bg_red
	},
})

vim.keymap.set("v", "<leader>h", ":<c-u>HSHighlight 0<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>h", ":<c-u>HSRmHighlight rm_all<cr>", { noremap = true, silent = true })
