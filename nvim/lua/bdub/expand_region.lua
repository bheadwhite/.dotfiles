local opts = { noremap = true, silent = true }

-- local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap
keymap("n", "<Tab>", "<Plug>(expand_region_expand)", opts)
keymap("v", "<Tab>", "<Plug>(expand_region_expand)", opts)
keymap("n", "<S-Tab>", "<Plug>(expand_region_shrink)", opts)
keymap("v", "<S-Tab>", "<Plug>(expand_region_shrink)", opts)
