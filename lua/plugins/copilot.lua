return {
	"github/copilot.vim",
	init = function()
		vim.g.copilot_no_tab_map = true
	end,
	config = function()
		local keymap = vim.api.nvim_set_keymap
		local opts = { expr = true, script = true, silent = true }

		keymap("i", "<C-V>", "copilot#Accept('<CR>')", opts)
		keymap("i", "<C-M-n>", "copilot#Next()", opts)
		keymap("i", "<C-M-p>", "copilot#Previous()", opts)
	end,
}
