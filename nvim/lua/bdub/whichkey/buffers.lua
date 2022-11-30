local exports = {
  write = { "<cmd>w!<cr>", "Write" },
  close = { "<cmd>Bdelete!<CR>", "Close" },
  nohl = { "<cmd>nohlsearch<CR>", "No Highlight" },
  close_all_but_this_one = { "<cmd>%bd|e#|bd#<cr>", "Close All But This One" },
  get_path = { "<cmd>lua require 'bdub.commands.file_path'.get_file_path()<cr>", "Get File Path" },
  zoom = { ":MaximizerToggle<CR>", "Zoom" },
  rename_file = { "<cmd>lua require 'nvim-lsp-ts-utils'.rename_file()<cr>", "Rename File" },
  toggle_tree = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
  quit = { "<cmd>q!", "Quit" },
}

return exports
