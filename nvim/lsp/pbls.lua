return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/pbls" },
  filetypes = { "proto" },
  root_markers = { "proto/" }, -- Adjust this if your proto files are in a different directory
  on_attach = require("bdub.lsp_helpers").on_attach,
}
