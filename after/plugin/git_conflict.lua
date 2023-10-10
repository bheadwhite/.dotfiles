vim.api.nvim_exec([[ hi everest_blue_bg guibg=#384b55 ]], false)
vim.api.nvim_exec([[ hi everest_yellow_bg guibg=#45443c ]], false)
vim.api.nvim_exec([[ hi everest_green_bg guibg=#3c4841 ]], false)

require("git-conflict").setup({
	highlights = {
		incoming = "everest_green_bg",
		current = "everest_blue_bg",
	},
})

vim.keymap.set(
	"n",
	"<leader>gcq",
	":GitConflictListQf<CR>",
	{ desc = "open git conflicts", noremap = true, silent = true }
)
vim.keymap.set("n", "<leader>gco", ":GitConflictChooseOurs", { desc = "Choose Ours" })
vim.keymap.set("n", "<leader>gct", ":GitConflictChooseTheirs", { desc = "Choose Theirs" })
vim.keymap.set("n", "<leader>gcb", ":GitConflictChooseBoth", { desc = "Choose Both " })
