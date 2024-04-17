local grapple = require("grapple")

grapple.setup({
	scope = "git_branch",
	name_pos = "start",
	win_opts = {
		width = 0.9,
		height = 0.8,
		relative = "editor",
		title_pos = "center",
		focusable = true,
		title = "hello world",
	},
})

local function getName()
	local name = vim.fn.input("a man needs a name: ")
	if name == nil or name == "" then
		return nil
	end

	return name
end

vim.keymap.set("n", "<leader>a", function()
	local name = getName()
	grapple.tag({ name = name })
end, { silent = true, desc = "grapple tag" })
vim.keymap.set("n", "<leader>A", function()
	local name = getName()
	grapple.tag({ name = name, scope = "global" })
end, { silent = true, desc = "grapple global tag" })
vim.keymap.set("n", "<C-M-p>", function()
	grapple.toggle_tags()
end, { silent = true, desc = "toggle tags" })
vim.keymap.set("n", "<C-S-M-p>", function()
	grapple.toggle_tags({
		scope = "global",
	})
end, { silent = true, desc = "toggle global tags" })
