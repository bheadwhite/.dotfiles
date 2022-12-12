local exports = {

  buffers = {
    "<cmd>lua require 'telescope.builtin'.buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>",
    "Buffers",
  },
  find_files = {
    "<cmd>lua require 'telescope.builtin'.find_files()<CR>",
    "Find Files",
  },
  live_grep = { "<cmd>lua require 'telescope.builtin'.live_grep()<CR>", "Grep Files" },
  recent_files = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
  lsp_implementations = { "<cmd>lua require 'telescope.builtin'.lsp_implementations()<cr>", "implementions" },
  git_status = { "<cmd>lua require 'telescope.builtin'.git_status()<cr>", "git status" },
  symbols = { "<cmd>lua require 'telescope.builtin'.lsp_document_symbols()<cr>", "symbols" },
  diagnostics = { "<cmd>lua require 'telescope.builtin'.diagnostics()<cr>", "diagnostics" },
  definitions_split = {
    "<cmd>lua require 'telescope.builtin'.lsp_definitions({jump_type = 'split'})<cr>",
    "definition split",
  },
  definitions_vsplit = {
    "<cmd>lua require 'telescope.builtin'.lsp_definitions({jump_type = 'vsplit'})<cr>",
    "definition vsplit",
  },
  document_symbols = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
  workspace_symbols = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
  checkout_branch = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
  colorscheme = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
  help_tags = { "<cmd>Telescope help_tags<cr>", "Find Help" },
  man_pages = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
  registers = { "<cmd>Telescope registers<cr>", "Registers" },
  keymaps = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
  commands = { "<cmd>Telescope commands<cr>", "Commands" },
}

return exports
