local dap_install = require("dap-install")

local DAP_PATH = os.getenv("HOME") .. "/.config/dapinstall"
local NODE_DAP_PATH = DAP_PATH .. "/jsnode/vscode-node-debug2/out/src/nodeDebug.js"

dap_install.setup({
	installation_path = DAP_PATH,
})

local dap_ui = require("dapui")
dap_ui.setup()

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