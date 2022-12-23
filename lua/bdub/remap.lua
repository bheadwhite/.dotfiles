vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function add_desc(desc, table)
	local opts = {}
	opts.desc = desc
	opts = vim.tbl_extend("force", opts, table or {})
	return opts
end

vim.keymap.set(
	"n",
	"<leader>e",
	"<cmd>Telescope file_browser path=%:p:h<CR>",
	add_desc("Open file explorer", { noremap = true })
)

-- vim.keymap.set("n", "<C-M-S-j>", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>P", [["_dP]], add_desc("Paste over selection"))

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], add_desc("Copy to system clipboard"))
vim.keymap.set("n", "<leader>Y", [["+Y]], add_desc("Copy line to system clipboard"))

-- yank til the end of the line
vim.keymap.set("n", "S", "vg_", { noremap = true, silent = true })

-- keep put register consistent for visual puts
vim.keymap.set("v", "p", '"_dP', { noremap = true, silent = true })

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

vim.keymap.set("n", "<leader>j", "<cmd>cnext<CR>zz", add_desc("Next quickfix"))
vim.keymap.set("n", "<leader>k", "<cmd>cprev<CR>zz", add_desc("Previous quickfix"))
vim.keymap.set("n", "<leader>>", "<cmd>lnext<CR>zz", add_desc("Next location"))
vim.keymap.set("n", "<leader><", "<cmd>lprev<CR>zz", add_desc("Previous location"))

vim.keymap.set(
	"n",
	"<leader>S",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	add_desc("Search and replace under cursor")
)
vim.keymap.set("n", "<leader>X", "<cmd>!chmod +x %<CR>", add_desc("Make file executable"))
vim.keymap.set("n", "<leader>w", ":w<CR>", add_desc("write", { silent = true }))
vim.keymap.set("n", "<leader>q", function()
	vim.cmd.Bdelete()
	vim.cmd.q()
end, add_desc("close buffer and close split", { noremap = true, silent = true }))
vim.keymap.set(
	"n",
	"<C-M-r>",
	"<cmd>lua require'bdub.commands'.copy_file_path()<cr>",
	{ noremap = true, silent = true }
)

local keymap = vim.api.nvim_set_keymap
local options = { noremap = true, silent = true }

-- window navigation
keymap("n", "<C-M-S-h>", "<C-w>h", options)
keymap("n", "<C-M-S-j>", "<C-w>j", options)
keymap("n", "<C-M-S-k>", "<C-w>k", options)
keymap("n", "<C-M-S-l>", "<C-w>l", options)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", options)
keymap("n", "<C-Down>", ":resize +2<CR>", options)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", options)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", options)

-- Navigate buffers
keymap("n", "<C-,>", ":bp<CR>", options)
keymap("n", "<C-.>", ":bn<CR>", options)

keymap("n", "<leader>h", ":nohl<CR>", add_desc("nohl", options))
keymap("n", "J", "}", options)
keymap("n", "K", "{", options)
keymap("n", "*", ":keepjumps normal! mi*`i<CR>", options)
