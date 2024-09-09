return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim", "rcarriga/nvim-notify" },
  config = function()
    local helpers = require("bdub.lsp_helpers")
    require("mason").setup()
    require("mason-lspconfig").setup({
      handlers = {
        ["lua_ls"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.lua_ls.setup({
            on_attach = helpers.on_attach,
            settings = {
              Lua = {
                diagnostics = {
                  globals = { "vim" },
                  disable = { "lowercase-global" },
                },
              },
            },
          })
        end,
        ["pyright"] = function()
          local lspconfig = require("lspconfig")
          lspconfig.pyright.setup({
            on_attach = helpers.on_attach,
            settings = {
              python = {
                analysis = {
                  typeCheckingMode = "standard", --basic, standard, strict
                  diagnosticSeverityOverrides = {
                    -- reportArgumentType = "information",
                    -- reportUnusedFunction = "warning",
                    -- reportUnusedVariable = "information",
                    -- reportUnusedExpression = "information",
                    -- reportAssignmentType = "information",
                    -- reportUnknownVariableType = false,
                    -- reportMissingTypeStubs = false,
                    -- reportUnknownMemberType = "warning",
                    -- reportUnknownParameterType = false,
                    -- reportMissingTypeArgument = false,
                    -- reportUnknownArgumentType = false,
                    -- reportAttributeAccessIssue = "warning",
                    -- reportReturnType = "information",
                    -- reportIndexIssue = "information",
                    -- reportOperatorIssue = "information",
                    -- reportGeneralTypeIssues = "information",
                    -- reportOptionalIterable = "information",
                  },
                },
                venvPath = "/Users/brent.whitehead/.python_env/envs/python-3-11",
              },
            },
          })
        end,

        function(serverName)
          local server = require("lspconfig")[serverName]
          local on_attach = server.on_attach
          server.on_attach = function(client, bufnr)
            if on_attach then
              on_attach(client, bufnr)
            end
            helpers.on_attach(client, bufnr)
          end

          require("lspconfig")[serverName].setup(server)
        end,
      },
    })
  end,
}
