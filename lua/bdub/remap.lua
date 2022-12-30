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

local normal_keymaps = {
	{ "gj", "mzJ`z", "join" },
	{ "<c-d>", "<c-d>zz", "half page down" },
	{ "<C-u>", "<C-u>zz", "half page up" },
	{ "n", "nzzzv", "next with cursor centered" },
	{ "N", "Nzzzv", "prev with cursor centered" },
	{ "<leader>Y", [["+Y]], "Copy line to system clipboard" },
	{ "S", "vg_", "select until EOL" },
	{ "Q", "<nop>", "disable ex mode" },
	{ "<leader>j", "<cmd>cnext<CR>zz", "next quickfix" },
	{ "<leader>k", "<cmd>cprev<CR>zz", "prev quickfix" },
	{ "<leader>>", "<cmd>lnext<CR>zz", "next location" },
	{ "<leader><", "<cmd>lprev<CR>zz", "prev location" },
	{ "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "substitue under cursor" },
	{ "<leader>X", "<cmd>!chmod +x %<CR>", "make file executable" },
	{ "<leader>w", ":w<CR>", "write" },
	{ "<leader>q", vim.cmd.q, "close buffer" },
	{ "<C-M-r>", commands.copy_file_path, "copy file path" },
	{ "<C-M-S-h>", "<C-w>h", "left window nav" },
	{ "<C-M-S-j>", "<C-w>j", "down window nav" },
	{ "<C-M-S-k>", "<C-w>k", "up window nav" },
	{ "<C-M-S-l>", "<C-w>l", "right window nav" },
	{ "<C-Up>", ":resize -2<CR>", "resize split -2" },
	{ "<C-Down>", ":resize +2<CR>", "resize split +2" },
	{ "<C-Left>", ":vertical resize -2<CR>", "resize vertical split -2" },
	{ "<C-Right>", ":vertical resize +2<CR>", "resize vertical split +2" },
	{ "<C-,>", ":bp<CR>", "prev buffer" },
	{ "<C-.>", ":bn<CR>", "next buffer" },
	{ "<leader>h", ":nohl<CR>", "nohl" },
	{ "*", ":keepjumps normal! mi*`i<CR>", "for jumps" },
}

for _, value in ipairs(normal_keymaps) do
	vim.keymap.set("n", value[1], value[2], add_desc(value[3], options))
end

-- system clipboard
vim.keymap.set("x", "<leader>P", [["_dP]], add_desc("Paste over selection"))
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], add_desc("Copy to system clipboard"))
vim.keymap.set("v", "p", '"_dP', options)
vim.keymap.set("c", "<M-k>", "\\(.*\\)", { desc = "one eyed fighting kirby" })
vim.keymap.set({ "n", "v" }, "J", "}", options)
vim.keymap.set({ "n", "v" }, "K", "{", options)
