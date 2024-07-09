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
			on_attach = function(_, bufnr)
				helpers.on_attach(bufnr)
			end,
			settings = {
				python = {
					analysis = {
						typeCheckingMode = "basic",
					},
					venvPath = "/Users/brent.whitehead/Library/Caches/pypoetry/virtualenvs",
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

require("lspconfig").pyright.setup({})

require("mason-lspconfig").setup({
	handlers = handlers,
})

-- vim.diagnostic.config({
--   virtual_text = true,
-- })
