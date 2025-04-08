return {
  "williamboman/mason.nvim",
  dependencies = { "rcarriga/nvim-notify" },
  config = function()
    require("mason").setup()
    vim.lsp.enable({ "lua-language-server", "gopls", "pbls", "biome", "pyright", "typescript-language-server" })

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
          return
        end

        if client:supports_method("textDocument/completion") then
          vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
      end,
    })
  end,
}
