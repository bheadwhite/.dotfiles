require("bdub.options")
require("bdub.diagnostics")
require("bdub.remap")
require("bdub.inactive_backgrounds")
require("bdub.autocommands")
require("bdub.buf-only")

local augroup = vim.api.nvim_create_augroup
local bdubsGroup = augroup("bdub", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

function R(name)
	require("plenary.reload").reload_module(name)
end

vim.cmd([[
highlight NormalSB guibg=#272e33
]])

--
autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

-- remove trailing whitespaces
autocmd({ "BufWritePre" }, {
	group = bdubsGroup,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.g.copilot_no_tab_map = true
