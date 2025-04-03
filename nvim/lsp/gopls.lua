return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/gopls" },
  filetypes = { "go", "gomod" },
  root_markers = { "go.mod", ".git/" },
  settings = {
    gopls = {
      gofumpt = true, -- Use gofumpt for formatting
      staticcheck = true, -- Enable staticcheck for linting
      analyses = {
        unusedparams = true, -- Enable unused parameter checks
      },
      hints = {
        assignVariableTypes = true, -- Show variable type hints
      },
    },
  },
  on_attach = require("bdub.lsp_helpers").on_attach,
}
