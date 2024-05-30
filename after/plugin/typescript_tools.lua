local api = require("typescript-tools.api")
require("typescript-tools").setup({
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	settings = {
		tsserver_file_preferences = {
			importModuleSpecifierPreference = "non-relative",
		},
	},
	handlers = {
		["textDocument/publishDiagnostics"] = api.filter_diagnostics({
			2311,
			80006,
			80001,
			7044,
			7043,
		}),
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("TS", { clear = true }),
	desc = "TS add missing imports",
	pattern = { "*.ts", "*.tsx" },
	callback = function()
		pcall(vim.cmd, [[TSToolsAddMissingImports sync]])
		vim.lsp.buf.format()
	end,
})

vim.keymap.set("n", "<leader>r", "<cmd>TSToolsRenameFile<CR>", { noremap = true, silent = true })
