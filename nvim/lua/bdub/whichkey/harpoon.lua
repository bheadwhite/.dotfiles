local exports = {
  ui = { "<cmd>lua require 'harpoon.ui'.toggle_quick_menu()<cr>", "Menu" },
  go_next = { "<cmd>lua require 'harpoon.ui'.nav_next()<cr>", "Go Next" },
  go_prev = { "<cmd>lua require 'harpoon.ui'.nav_prev()<cr>", "Go Prev" },
  add_file = { "<cmd>lua require 'harpoon.mark'.add_file()<cr>", "Add File" },
}

return exports
