local opts = { noremap = true, silent = true }

-- local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Better window navigation
keymap("n", "<C-,>", "<C-w>h", opts)
keymap("n", "<C-S-j>", "<C-w>j", opts)
keymap("n", "<C-S-k>", "<C-w>k", opts)
keymap("n", "<C-.>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<C-l>", ":bnext<CR>", opts)
keymap("n", "<C-h>", ":bprevious<CR>", opts)

-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- keep put register consistent for visual puts
keymap("v", "p", '"_dP', opts)

-- diagnostics
keymap("n", "<M-S-h>", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", opts)
keymap("n", "<M-S-l>", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", opts)
