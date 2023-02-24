local status_ok, oil = pcall(require, "oil")
if not status_ok then
	return
end

local actions = require("oil.actions")

oil.setup({
	keymaps = {
		["<C-h>"] = false,
		["<C-l>"] = false,
		["<C-j>"] = false,
		["<C-k>"] = false,
		["<C-S-S>"] = actions.select_split,
		["F"] = function()
			local dir = oil.get_current_dir()
			oil.close()

			require("telescope.builtin").live_grep({
				prompt_title = "grep files in " .. dir,
				search_dirs = { dir },
			})
		end,
	},
})

function InOil()
	return vim.bo.filetype == "oil"
end

function InNeoTree()
	return vim.bo.filetype == "neo-tree"
end

function ToggleOil()
	if InNeoTree() then
		vim.cmd([[Neotree toggle]])
		return
	end

	if InOil() then
		oil.close()
	else
		oil.open()
	end
end

vim.keymap.set("n", "<leader>e", ToggleOil, { noremap = true, desc = "toggle oil" })
