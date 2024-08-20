return {
	"folke/noice.nvim",
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		"rcarriga/nvim-notify",
	},
	event = "VeryLazy",
	opts = {
		-- add any options here
		messages = {
			enabled = false,
			view = "mini", -- default view for messages
			view_error = "mini", -- view for errors
			view_warn = "mini", -- view for warnings
			view_history = "messages", -- view for :messages
			view_search = "mini", -- v,
		},
		notify = {
			enabled = false,
		},
		signature = {
			auto_open = {
				enabled = false,
			},
		},
	},
}
