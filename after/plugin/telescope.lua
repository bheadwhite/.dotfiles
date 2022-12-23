local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
	return
end

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "find files" })
vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "git files" })
vim.keymap.set("n", "<leader>p", builtin.oldfiles, { desc = "recent files" })

local operator_path_display = function(_, file_path) -- absolute path
	if not string.find(file_path, "^/Users/brent.whitehead/") then
		return file_path
	end

	local relative_path = string.gsub(file_path, "/Users/brent.whitehead(.*)", "~%1")

	if string.find(relative_path, "ui/operator/src") then
		local result = string.gsub(relative_path, ".*/?ui/operator/src/(.*)", "operator/%1")
		print(result)
		return result
	elseif string.find(relative_path, "Projects/neo/commons/ui") then
		local result = string.gsub(relative_path, ".*/?(commons/)ui/(.*)", "%1%2")
		print(result)
		return result
	end

	return relative_path
end

telescope.setup({
	pickers = {
		buffers = {
			path_display = { "tail" },
		},
	},
	defaults = {
		prompt_prefix = " ",
		selection_caret = " ",
		layout_strategy = "vertical",
		path_display = operator_path_display,

		layout_config = {
			height = 0.9,
			preview_cutoff = 60,
		},

		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})

require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")
