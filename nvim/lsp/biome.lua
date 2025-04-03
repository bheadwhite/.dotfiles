return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/biome" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json" },
  root_markers = { ".biomeconfig.json", "biome.config.js", "biome.config.ts", "biome.json" },
  settings = {
    biome = {
      organizeImports = {
        enabled = false, -- Disable automatic import organization
      },
    },
  },
  on_attach = require("bdub.lsp_helpers").on_attach,
}
