require("noice").setup({
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
})
