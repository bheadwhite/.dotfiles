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
        if not client then
          return
        end

        if client:supports_method("textDocument/completion") then
          vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end

        if client.name == "vtsls" then
          local orig = vim.lsp.handlers["textDocument/publishDiagnostics"]
          vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
            if result and result.diagnostics then
              ignore_codes = require("bdub.diagnostics").typescript_ignore_codes
              result.diagnostics = vim.tbl_filter(function(d)
                return not vim.tbl_contains(ignore_codes, d.code)
              end, result.diagnostics)
            end
            orig(err, result, ctx, config)
          end
        end
      end,
    })
  end,
}
