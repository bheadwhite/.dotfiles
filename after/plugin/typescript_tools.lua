local api = require("typescript-tools.api")
print("tyrpescript tools")
require("typescript-tools").setup({
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
	desc = "TS format and add missing imports",
	pattern = { "*.ts", "*.tsx" },
	callback = function()
		vim.lsp.buf.format()
		vim.cmd([[TSToolsAddMissingImports]])
		vim.defer_fn(function()
			-- Using ':noautocmd w' to avoid triggering BufWritePre again
			vim.cmd("noautocmd w")
		end, 1000) -- Delay in milliseconds, adjust as necessary
	end,
})
