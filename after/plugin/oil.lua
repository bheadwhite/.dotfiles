local status_ok, oil = pcall(require, "oil")
if not status_ok then
	return
end

local actions = require("oil.actions")
local custom_commands = require("bdub.commands")
local PlenaryPath = require("plenary.path")

oil.setup({
	keymaps = {
		["<C-h>"] = false,
		["<C-l>"] = false,
		["<C-j>"] = false,
		["<C-k>"] = false,
		["<C-S-S>"] = actions.select_split,
		["<C-M-r>"] = function()
			local entry = oil.get_cursor_entry()
			local path = oil.get_current_dir()
			local full_path = path .. entry.name

			local relative = PlenaryPath:new(full_path):make_relative()

			custom_commands.copy_operator_file_path(relative)
		end,
		["F"] = function()
			local entry = oil.get_cursor_entry()
			local dir = oil.get_current_dir()

			if entry.type == "directory" then
				dir = dir .. entry.name
			end

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

function OpenOil()
	if InOil() then
		return
	end

	oil.open()
end

vim.keymap.set("n", "<leader>e", ToggleOil, { noremap = true, desc = "toggle oil" })
vim.keymap.set("n", "-", OpenOil, { noremap = true, desc = "open oil" })
