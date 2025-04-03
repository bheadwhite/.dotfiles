local stdpath = vim.fn.stdpath("data")

return {
  cmd = { stdpath .. "/mason/bin/lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json" },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }, -- Recognize 'vim' as a global variable
        disable = { "lowercase-global" }, -- Disable warning for lowercase globals
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- Load runtime files
      },
    },
  },
  on_attach = require("bdub.lsp_helpers").on_attach,
}
