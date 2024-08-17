return {
	"zbirenbaum/copilot.lua",
	init = function()
		vim.g.copilot_no_tab_map = true
	end,
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			panel = {
				enabled = true,
				-- keymap = {
				-- 	open = "<C-Space>",
				-- },
			},
			suggestion = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept = "<C-V>",
				},
			},
		})
	end,
}
