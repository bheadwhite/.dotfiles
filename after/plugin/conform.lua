local conform = require("conform")

conform.setup({
	-- log_level = vim.log.levels.DEBUG,
	formatters = {
		blackd = {
			command = "blackd-client",
			args = {
				"--line-length",
				"120",
			},
			stdin = true,
			require_cwd = false,
			exit_codes = { 0 },
		},
		black = {
			prepend_args = {
				"--line-length",
				"120",
			},
		},
	},
	formatters_by_ft = {
		python = { "blackd" },
		lua = { "stylua" },
		javascript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescript = { "prettierd" },
		typescriptreact = { "prettierd" },
		json = { "prettierd" },
	},
	format_on_save = {
		timeout_ms = 3000,
	},
})
