local gomove = require("gomove")

gomove.setup({
	-- whether or not to map default key bindings, (true/false)
	map_defaults = false,
	-- whether or not to reindent lines moved vertically (true/false)
	reindent = true,
	-- whether or not to undojoin same direction moves (true/false)
	undojoin = true,
	-- whether to not to move past end column when moving blocks horizontally, (true/false)
	move_past_end_col = true,
})

vim.keymap.set("n", "<M-[>", "<Plug>GoNSMUp", { noremap = false })
vim.keymap.set("n", "<M-]>", "<Plug>GoNSMDown", { noremap = false })
vim.keymap.set("x", "<M-[>", "<Plug>GoVSMUp", { noremap = false })
vim.keymap.set("x", "<M-]>", "<Plug>GoVSMDown", { noremap = false })

vim.keymap.set("n", "<M-S-j>", "<Plug>GoNSDDown", { noremap = false })
vim.keymap.set("n", "<M-S-k>", "<Plug>GoNSDUp", { noremap = false })
vim.keymap.set("x", "<M-S-j>", "<Plug>GoVSDDown", { noremap = false })
vim.keymap.set("x", "<M-S-k>", "<Plug>GoVSDUp", { noremap = false })

vim.keymap.set("x", ">", "<Plug>GoVSMRight", { noremap = false })
vim.keymap.set("x", "<", "<Plug>GoVSMLeft", { noremap = false })
