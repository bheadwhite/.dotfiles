local conform = require("conform")

conform.setup({
	formatters = {
		black = {
			append_args = { "--line-length", "120", "--preview" },
		},
	},
	formatters_by_ft = {
		python = { "black" },
		lua = { "stylua" },
		javascript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescript = { "prettierd" },
		typescriptreact = { "prettierd" },
		json = { "prettierd" },
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		conform.format({ bufnr = args.bufnr })
	end,
})
