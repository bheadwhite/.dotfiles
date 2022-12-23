local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>z", ":MaximizerToggle<CR>", vim.tbl_extend("force", opts, { desc = "zoom" }))
