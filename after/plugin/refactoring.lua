local refactoring = require("refactoring")

refactoring.setup({})

vim.keymap.set({ "n", "v" }, "<leader>rf", function()
	refactoring.refactor("Extract Function")
end, { silent = true, noremap = true, expr = false, desc = "Extract Function" }) })
