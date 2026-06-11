return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/svelteserver", "--stdio" },
  filetypes = { "svelte" },
  root_markers = { "svelte.config.js", "svelte.config.ts", "package.json", ".git" },
  on_attach = require("bdub.lsp_helpers").on_attach,
}
