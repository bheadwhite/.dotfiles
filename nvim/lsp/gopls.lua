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
        ST1003 = false, -- Don't flag initialism casing (e.g. aipApi vs aipAPI)
        ST1020 = false, -- Don't flag strict comment formatting on methods (e.g. "MethodName is a method" vs "MethodName is a method.")
        ST1021 = false, -- comment stuff...
      },
      hints = {
        assignVariableTypes = true, -- Show variable type hints
      },
    },
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gp", "<cmd>lua require('bdub.lsp_helpers').jumpToGolangReference()<CR>", {
      noremap = true,
      silent = true,
      desc = "Jump to golang reference",
    })

    require("bdub.lsp_helpers").on_attach(client, bufnr)
  end,
}
