local helpers = require("bdub.lsp_helpers")

require("mason").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

local handlers = {
	["lua_ls"] = function()
		local lspconfig = require("lspconfig")
		lspconfig.lua_ls.setup({
			on_attach = function(_, bufnr)
				helpers.on_attach(bufnr)
			end,
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
			on_attach = function(client, bufnr)
				client.capabilities = capabilities

				helpers.on_attach(bufnr)
			end,
			settings = {
				python = {
					analysis = {
						typeCheckingMode = "standard",
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
		server.capabilities = vim.tbl_deep_extend("force", capabilities, server.capabilities or {})
		local on_attach = server.on_attach
		server.on_attach = function(client, bufnr)
			if on_attach then
				on_attach(client, bufnr)
			end
			helpers.on_attach(bufnr)
		end

		require("lspconfig")[serverName].setup(server)
	end,
}

require("mason-lspconfig").setup({
	handlers = handlers,
})
