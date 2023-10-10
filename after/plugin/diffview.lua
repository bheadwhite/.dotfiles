local actions = require("diffview.actions")

vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "open diffview", noremap = true, silent = true })
vim.keymap.set("n", "<leader>gg", ":DiffviewClose<CR>", { desc = "close diffview", noremap = true, silent = true })

require("diffview").setup({
	keymaps = {
		view = {
			{ "n", "gf", actions.goto_file_tab, { desc = "Open the file in a new split in the previous tabpage" } },
		},
		file_panel = {
			{ "n", "gf", actions.goto_file_tab, { desc = "Open the file in a new split in the previous tabpage" } },
		},
	},
})
