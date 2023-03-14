local dap_install = require("dap-install")

local DAP_PATH = os.getenv("HOME") .. "/.config/dapinstall"
local NODE_DAP_PATH = DAP_PATH .. "/jsnode/vscode-node-debug2/out/src/nodeDebug.js"

dap_install.setup({
	installation_path = DAP_PATH,
})

local dap_ui = require("dapui")
dap_ui.setup()
local jester = require("jester")

jester.setup({
	cmd = "./node_modules/.bin/jest -t '$result' -- $file", -- run command
	identifiers = { "test", "it" }, -- used to identify tests
	prepend = { "describe" }, -- prepend describe blocks
	expressions = { "call_expression" }, -- tree-sitter object used to scan for tests/describe blocks
	path_to_jest_run = "jest", -- used to run tests
	path_to_jest_debug = "./node_modules/.bin/jest", -- used for debugging
	terminal_cmd = ":vsplit | terminal", -- used to spawn a terminal for running tests, for debugging refer to nvim-dap's config
	dap = { -- debug adapter configuration
		type = "node2",
		request = "launch",
		cwd = vim.fn.getcwd(),
		runtimeArgs = { "--inspect-brk", "$path_to_jest", "--no-coverage", "-t", "$result", "--", "$file" },
		args = { "--no-cache" },
		sourceMaps = false,
		protocol = "inspector",
		skipFiles = { "<node_internals>/**/*.js" },
		console = "integratedTerminal",
		port = 9229,
		disableOptimisticBPs = true,
	},
})

local dap = require("dap")

dap.adapters.node2 = {
	type = "executable",
	command = "node",
	args = {
		NODE_DAP_PATH,
	},
}

dap.configurations.javascript = {
	{
		type = "node2",
		name = "Attach",
		request = "attach",
		program = "${file}",
		cwd = vim.fn.expand("%:p:h"),
		sourceMaps = true,
		protocol = "inspector",
	},
	{
		type = "node2",
		request = "launch",
		name = "Jest test",
		runtimeExecutable = "node",
		runtimeArgs = { "--inspect-brk", "${workspaceFolder}/node_modules/.bin/jest" },
		args = { "${file}", "--runInBand", "--no-cache", "--coverage", "false" },
		rootPath = "${workspaceFolder}",
		cwd = "${workspaceFolder}",
		console = "integratedTerminal",
		internalConsoleOptions = "neverOpen",
		sourceMaps = "inline",
		port = 9229,
		skipFiles = { "<node_internals>/**", "node_modules/**" },
		protocol = "inspector",
	},
}

dap.configurations.typescript = dap.configurations.javascript

vim.keymap.set("n", "<leader>dd", dap.continue, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dc", dap.continue, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dj", dap.step_into, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dl", dap.step_over, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dk", dap.step_out, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dui", dap_ui.toggle, { noremap = true, silent = true })
vim.keymap.set("n", "<C-M-S-t>", jester.run, { noremap = true, silent = true })
vim.keymap.set("n", "<C-M-S-d>", jester.debug, { noremap = true, silent = true })
