require("maximize").setup()

vim.keymap.set(
	"n",
	"<leader>z",
	"<Cmd>lua require('maximize').toggle()<CR>",
	{ noremap = true, silent = true, desc = "zoom" }
)
