return {
	"booperlv/nvim-gomove",
	config = function()
		require("gomove").setup({
			-- whether or not to map default key bindings, (true/false)
			map_defaults = false,
			-- whether or not to reindent lines moved vertically (true/false)
			reindent = true,
			-- whether or not to undojoin same direction moves (true/false)
			undojoin = true,
			-- whether to not to move past end column when moving blocks horizontally, (true/false)
			move_past_end_col = true,
		})

		local keymap_opts = { noremap = true, silent = true }

		vim.keymap.set("n", "<M-[>", "<Plug>GoNSMUp", keymap_opts)
		vim.keymap.set("n", "<M-]>", "<Plug>GoNSMDown", keymap_opts)
		vim.keymap.set("x", "<M-[>", "<Plug>GoVSMUp", keymap_opts)
		vim.keymap.set("x", "<M-]>", "<Plug>GoVSMDown", keymap_opts)

		vim.keymap.set("n", "<M-S-j>", "<Plug>GoNSDDown", keymap_opts)
		vim.keymap.set("n", "<M-S-k>", "<Plug>GoNSDUp", keymap_opts)
		vim.keymap.set("x", "<M-S-j>", "<Plug>GoVSDDown", keymap_opts)
		vim.keymap.set("x", "<M-S-k>", "<Plug>GoVSDUp", keymap_opts)

		vim.keymap.set("x", ">", "<Plug>GoVSMRight", keymap_opts)
		vim.keymap.set("x", "<", "<Plug>GoVSMLeft", keymap_opts)
	end,
}
