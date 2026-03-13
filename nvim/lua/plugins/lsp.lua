return {
  "williamboman/mason.nvim",
  dependencies = { "rcarriga/nvim-notify" },
  cond = not vim.g.vscode,
  config = function()
    require("mason").setup()

    vim.lsp.config("*", {
      capabilities = {
        general = {
          positionEncodings = { "utf-16" },
        },
      },
    })

    vim.lsp.enable({ "lua-language-server", "gopls", "biome", "pyright", "typescript-language-server", "protols" })
  end,
}
