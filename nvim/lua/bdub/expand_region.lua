local opts = { noremap = true, silent = true }

-- local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap
keymap("v", "<Tab>", "<Plug>(expand_region_expand)", opts)
keymap("v", "<S-Tab>", "<Plug>(expand_region_shrink)", opts)
