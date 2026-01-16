return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/protols" },
  filetypes = { "proto" },
  root_markers = { "proto/", "buf.yaml", ".git" },
  init_options = {
    include_paths = {
      vim.fn.expand("~/Projects/tcnapi/"),
      vim.fn.expand("~/code/googleapis"),
      vim.fn.expand("~/code/protobuf/src")
    }
  },
  on_attach = require("bdub.lsp_helpers").on_attach,
}
