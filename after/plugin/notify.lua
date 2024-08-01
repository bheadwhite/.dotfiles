local notify = require("notify")
notify.setup({
	stages = "static",
	render = "wrapped-compact",
	timeout = 3000,
})

vim.notify = notify
