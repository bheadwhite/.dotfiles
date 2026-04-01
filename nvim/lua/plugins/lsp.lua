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

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "typescript-language-server" then
          client.server_capabilities.semanticTokensProvider = nil
        end
      end,
    })
  end,
}
