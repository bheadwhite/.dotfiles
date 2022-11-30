local options = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap
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
keymap("n", "<Left>", "<C-w>h", options)
keymap("n", "<Down>", "<C-w>j", options)
keymap("n", "<Up>", "<C-w>k", options)
keymap("n", "<Right>", "<C-w>l", options)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", options)
keymap("n", "<C-Down>", ":resize +2<CR>", options)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", options)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", options)

-- Navigate buffers
keymap("n", "<C-,>", ":bp<CR>", options)
keymap("n", "<C-.>", ":bn<CR>", options)

--hover
keymap("n", "<C-A-i>", "<cmd>lua vim.lsp.buf.hover()<CR>", options)
keymap("n", "L", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", options)
keymap("n", "H", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", options)

-- Stay in indent mode
keymap("v", "<", "<gv", options)
keymap("v", ">", ">gv", options)

-- keep put register consistent for visual puts
keymap("v", "p", '"_dP', options)

-- diagnostics
keymap("n", "<M-S-h>", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", options)
keymap("n", "<M-S-l>", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", options)

keymap("n", "<C-M-r>", "<cmd>lua require'bdub.commands.file_path'.get_operator_file_path()<cr>", options)

keymap("n", "<C-M-p>", ":Telescope neoclip<cr>", options)
keymap("i", "<C-M-p>", "<c-o>:Telescope neoclip<cr>", options)

--rename
keymap("n", "<C-M-n>", "<cmd>lua vim.lsp.buf.rename()<cr>", options)

-- yank til the end of the line
keymap("n", "S", "vg_", options)
