vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function add_desc(desc, table)
	local opts = {}
	opts.desc = desc
	opts = vim.tbl_extend("force", opts, table or {})
	return opts
end

local commands = require("bdub.commands")
local options = { noremap = true, silent = true }

function ToggleGit()
	if vim.bo.filetype == "fugitive" then
		vim.cmd.q()
	else
		vim.cmd([[Git]])
	end
end

function vSplit()
	--vertically split the window and jump back to the original window
	vim.cmd([[vsplit | wincmd p]])
end

local function goToConstructor()
	local pattern = [[\v(export|constructor\()]]
	local constructor = [[\v(constructor\()]]

	local found = vim.fn.search(constructor, "nw")

	if found ~= 0 then
		vim.fn.setreg("/", constructor)
		vim.cmd("normal! /" .. constructor)

		vim.cmd("normal! n")
		vim.cmd("normal! zz")
	end
	vim.fn.setreg("/", pattern)
	vim.cmd("nohlsearch")
end

-- Function to check if the previous character is a whitespace
local function is_previous_char_whitespace()
	-- Get the current cursor position
	local _, col = unpack(vim.api.nvim_win_get_cursor(0))
	-- If the cursor is at the start of a line, there's no previous character
	if col == 0 then
		return false
	end
	-- Get the previous character
	local line = vim.api.nvim_get_current_line()
	local prev_char = line:sub(col, col)
	-- Check if the previous character is a whitespace
	return prev_char:match("%s") ~= nil
end

local highlight_under_cursor = function()
	local current_word = vim.fn.expand("<cword>")
	local found = vim.fn.search(current_word, "nw")

	if found == 0 then
		error("word not found")
	else
		--highlight the word and set as search register
		vim.fn.setreg("/", current_word)
		vim.cmd("set hlsearch")
		require("hlslens").start()

		--if previous character is alphanumeric, hit the "b" key to go back one word
		local isPreviousCharWhitespace = is_previous_char_whitespace()
		if not isPreviousCharWhitespace then
			vim.cmd("normal! b")
		end
	end
end

local normal_keymaps = {
	{ "gj", "mzJ`z", "join" },
	{ "<c-d>", "<c-d>zz", "half page down" },
	{ "<C-u>", "<C-u>zz", "half page up" },
	{ "n", "nzzzv", "next with cursor centered" },
	{ "N", "Nzzzv", "prev with cursor centered" },
	{ "S", "vg_", "select until EOL" },
	{ "Q", "<nop>", "disable ex mode" },
	{ "<leader>j", "<C-w>J", "move split down" },
	{ "<leader>k", "<C-w>K", "move split up" },
	{ "<C-M-g>", ToggleGit, "git" },
	{ "<leader>>", "<cmd>lnext<CR>zz", "next location" },
	{ "<leader><", "<cmd>lprev<CR>zz", "prev location" },
	{ "<leader>Ofj", commands.format_jq, "format json" },
	{ "<C-S-h>", "<cmd>bprev<CR>", "prev buffer" },
	{ "<C-S-l>", "<cmd>bnext<CR>", "next buffer" },
	{ "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "substitue under cursor" },
	{ "<leader>X", "<cmd>!chmod +x %<CR>", "make file executable" },
	{ "<leader>w", ":w<CR>", "write" },
	{ "<C-\\>", vSplit, "vertical split" },
	{ "<C-M-S-j>", "<cmd>cnext<CR>zz", "next quickfix" },
	{ "<C-M-S-k>", "<cmd>cprev<CR>zz", "prev quickfix" },
	{ "<C-M-S-q>", "<cmd>cclose<CR>", "close quickfix" },
	{ "<leader>q", vim.cmd.q, "close buffer" },
	{ "<C-M-r>", commands.copy_file_path, "copy file path" },
	{ "<C-Up>", ":resize -2<CR>", "resize split -2" },
	{ "<C-Down>", ":resize +2<CR>", "resize split +2" },
	{ "<C-Left>", ":vertical resize -2<CR>", "resize vertical split -2" },
	{ "<C-Right>", ":vertical resize +2<CR>", "resize vertical split +2" },
	{ "<C-,>", ":WinShift<CR>h<esc>", "move window left" },
	{ "<C-.>", ":WinShift<CR>l<esc>", "move window right" },
	{ "*", highlight_under_cursor, "for jumps" },
	{ "gn", goToConstructor, "go to constructor" },
}

for _, value in ipairs(normal_keymaps) do
	vim.keymap.set("n", value[1], value[2], add_desc(value[3], options))
end

--
local function set_custom_highlight()
	local background_color = "#1E2326" -- Replace with your desired color
	vim.cmd(string.format("highlight CustomFloating guibg=%s", background_color))
end

set_custom_highlight()

local function open_in_floating_window()
	-- Get the current file path
	local file_path = vim.api.nvim_buf_get_name(0)

	-- Get the dimensions of the current Neovim window
	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	-- Calculate the size and position of the floating window
	local win_width = math.ceil(width * 0.9)
	local win_height = math.ceil(height * 0.9)
	local row = math.ceil((height - win_height) / 2 - 2)
	local col = math.ceil((width - win_width) / 2)

	-- Create a new buffer
	local new_buf = vim.api.nvim_create_buf(false, true)

	-- get the file name and set it as the buffer title
	local file_name = vim.fn.fnamemodify(file_path, ":t")

	-- Create floating window with the new buffer
	local opts = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		zindex = 1,
		title = file_name,
	}

	local new_win = vim.api.nvim_open_win(new_buf, true, opts)
	-- Open the file in the floating window
	vim.api.nvim_command("edit " .. file_path)

	-- Enable line numbers in the floating window
	vim.api.nvim_win_set_option(new_win, "number", true)
	vim.api.nvim_win_set_option(new_win, "winhl", "Normal:CustomFloating")

	vim.keymap.set("n", "<leader>q", function()
		vim.api.nvim_win_close(new_win, true)
		vim.keymap.set("n", "<leader>q", vim.cmd.q, add_desc("close buffer"))
	end, { noremap = true, silent = true })
end

-- You can then call this function with `:lua open_buffer_in_floating_window()`

-- system clipboard
vim.keymap.set("x", "<leader>P", [["_dP]], add_desc("Paste over selection"))
vim.keymap.set("v", "p", '"_dP', options)
vim.keymap.set("v", "c", '"_di', options)
vim.keymap.set({ "n", "v" }, "<C-M-c>", [["+y]], add_desc("Copy to system clipboard"))

vim.keymap.set("c", "<M-k>", "\\(.*\\)", { desc = "one eyed fighting kirby" })
vim.keymap.set({ "n", "v" }, "j", "gj", options)
vim.keymap.set({ "n", "v" }, "k", "gk", options)
vim.keymap.set({ "n", "v" }, "J", function() end, options)
vim.keymap.set({ "n", "v" }, "L", "$", options)
vim.keymap.set({ "n", "v" }, "H", "_", options)
vim.keymap.set({ "n", "v", "x" }, "<C-k>", "<C-w>k", add_desc("move to top window"))
vim.keymap.set({ "n", "v", "x" }, "<C-l>", "<C-w>l", add_desc("move to right window"))
vim.keymap.set("n", "<leader>q", vim.cmd.q, add_desc("close buffer"))
vim.keymap.set({ "n", "v", "x" }, "<C-j>", "<C-w>j", add_desc("move to bottom window"))
vim.keymap.set({ "n", "v", "x" }, "<C-h>", "<C-w>h", add_desc("move to left window"))
vim.keymap.set({ "n", "v" }, "<leader><tab>l", vim.cmd.tabn, add_desc("next tab"))
vim.keymap.set({ "n", "v" }, "<leader><tab>h", vim.cmd.tabp, add_desc("prev tab"))
vim.keymap.set({ "n", "v" }, "<leader><tab><tab>", vim.cmd.tabe, add_desc("new tab"))
vim.keymap.set({ "n", "v" }, "<leader><tab><leader>", vim.cmd.tabc, add_desc("close tab"))
vim.keymap.set("n", "<leader>z", function()
	open_in_floating_window()
end, { noremap = true, silent = true, desc = "zoom" })

vim.keymap.set("n", "<esc>", "<cmd>noh<cr><esc>", add_desc("esc normal"))

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", options)
