local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
	return
end

local plenary = require("plenary")
local action_state = require("telescope.actions.state")
local commands = require("bdub.commands")

local function add_desc(desc, table)
	local opts = {}
	opts.desc = desc
	opts = vim.tbl_extend("force", opts, table or {})
	return opts
end

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "find files" })
vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "git files" })
vim.keymap.set("n", "<leader>p", builtin.oldfiles, { desc = "recent files" })
vim.keymap.set("n", "<leader>e", function()
	telescope.extensions.file_browser.file_browser({
		path = "%:p:h",
		cwd = vim.fn.expand("%:p:h"),
		respect_gitignore = false,
		grouped = true,
		initial_mode = "normal",
		layout_config = { height = 40 },
		hidden = true,
	})
end, add_desc("Open file explorer", { noremap = true }))
vim.keymap.set("n", "<leader>H", builtin.command_history, { desc = "command history" })

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

local default_opts = {
	path_display = operator_path_display,
	layout_strategy = "vertical",
	layout_config = {
		height = 0.9,
		preview_cutoff = 60,
	},
}

function copy_path_from_selection(bufnr)
	local current_picker = action_state.get_current_picker(bufnr)
	local selection = current_picker:get_selection()
	local path = selection[1]
	local cwd = vim.loop.cwd()
	local relative_path = plenary.Path:new(path):make_relative(cwd)

	commands.copy_operator_file_path(relative_path)
end

telescope.setup({
	pickers = {
		buffers = {
			path_display = { "tail" },
		},
		find_files = default_opts,
		git_files = default_opts,
		live_grep = default_opts,
		oldfiles = default_opts,
		lsp_references = default_opts,
		lsp_definitions = default_opts,
		lsp_type_definitions = default_opts,
		lsp_implementations = default_opts,
	},
	defaults = {
		prompt_prefix = " ",
		selection_caret = " ",
		mappings = {
			i = {
				["<C-M-r>"] = copy_path_from_selection,
			},
			n = {
				["<C-M-r>"] = copy_path_from_selection,
			},
		},
	},
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				layout_config = {
					width = 0.7,
				},
			}),
		},
	},
})

require("telescope").load_extension("fzf")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("ui-select")
