return {
	"pmizio/typescript-tools.nvim",
	branch = "bugfix/202",
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	config = function()
		local helpers = require("bdub.lsp_helpers")
		require("typescript-tools").setup({
			on_attach = function(client, bufnr)
				client.server_capabilities = vim.tbl_deep_extend("force", client.server_capabilities, {
					documentFormattingProvider = false,
					documentRangeFormattingProvider = false,
				})
				vim.keymap.set("n", "gp", helpers.jump_to_parent_class, { noremap = true, silent = true })
				vim.keymap.set("n", "<leader>r", "<cmd>TSToolsRenameFile<CR>", { noremap = true, silent = true })

				helpers.on_attach(client, bufnr)
			end,
			settings = {
				tsserver_file_preferences = {
					importModuleSpecifierPreference = "non-relative",
				},
				jsx_close_tag = {
					enabled = true,
				},
			},
			handlers = {
				-- ["textDocument/publishDiagnostics"] = api.filter_diagnostics({
				-- 	2311,
				-- 	80006,
				-- 	80001,
				-- 	7044,
				-- 	7043,
				-- }),
			},
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("TS", { clear = true }),
			desc = "TS add missing imports",
			pattern = { "*.ts", "*.tsx" },
			callback = function()
				--only call add missing imports if diagnostics are present and contain missing import code
				-- Check for diagnostics related to missing imports
				local diagnostics = vim.diagnostic.get(0) -- 0 means current buffer
				local has_missing_imports = false

				for _, diagnostic in ipairs(diagnostics) do
					if diagnostic.message:match("is not defined") or diagnostic.message:match("Cannot find name") then
						has_missing_imports = true
						break
					end
				end

				if has_missing_imports then
					pcall(vim.cmd, [[TSToolsAddMissingImports sync]])
				end
			end,
		})
	end,
}
