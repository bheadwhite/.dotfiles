local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
	return
end

local plenary = require("plenary")
local action_state = require("telescope.actions.state")
local commands = require("bdub.commands")
local actions = require("telescope.actions")
local winshift_lib = require("winshift.lib")
local builtin = require("telescope.builtin")

local function operator_path_display(_, file_path) -- absolute path
	if not string.find(file_path, "^/Users/brent.whitehead/") then
		return file_path
	end

	local relative_path = string.gsub(file_path, "/Users/brent.whitehead(.*)", "~%1")

	if string.find(relative_path, "ui/operator/src") then
		return string.gsub(relative_path, ".*/?ui/operator/src/(.*)", "operator/%1")
	elseif string.find(relative_path, "Projects/neo/commons/ui") then
		return string.gsub(relative_path, ".*/?(commons/)ui/(.*)", "%1%2")
	end

	return relative_path
end

local function file_name_only(_, file_path)
	return string.gsub(file_path, ".*/(.*)$", "%1")
end

local default_opts = {
	initial_mode = "normal",
	path_display = operator_path_display,
	layout_strategy = "vertical",
	layout_config = {
		height = 0.9,
		preview_cutoff = 60,
	},
}

local reference_opts = {
	initial_mode = "normal",
	path_display = file_name_only,
	layout_strategy = "vertical",
	layout_config = {
		height = 0.9,
		preview_cutoff = 60,
	},
}

local insert_mode_default = vim.tbl_extend("force", default_opts, {
	initial_mode = "insert",
})

local function openAndSwap(selection)
	actions.file_vsplit(selection)
	winshift_lib.start_swap_mode()
end

local function copy_path_from_selection(bufnr)
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
			initial_mode = "normal",
			path_display = { "tail" },
		},
		find_files = insert_mode_default,
		git_files = insert_mode_default,
		live_grep = insert_mode_default,
		oldfiles = default_opts,
		lsp_references = reference_opts,
		lsp_definitions = default_opts,
		lsp_type_definitions = default_opts,
		lsp_implementations = default_opts,
	},
	defaults = {
		prompt_prefix = " ",
		selection_caret = " ",
		file_ignore_patterns = {
			".*/webphone/",
			".*/pb_description/",
		},
		dynamic_preview_title = true,
		mappings = {
			i = {
				["<C-M-r>"] = copy_path_from_selection,
				["<c-f>"] = actions.to_fuzzy_refine,
				["<C-v>"] = openAndSwap,
				["<C-u>"] = false,
				["<C-M-S-l>"] = function()
					print("target rpc references")
					local val = vim.api.nvim_win_get_cursor(0)
					local string = "!mock !fixture !test"
					local startRow = val[1] - 1
					local startCol = val[2]
					vim.api.nvim_buf_set_text(0, startRow, startCol, startRow, startCol, { string })

					vim.api.nvim_win_set_cursor(0, { 1, #tostring(vim.api.nvim_get_current_line()) })
				end,
			},
			n = {
				["<C-M-r>"] = copy_path_from_selection,
				["<C-v>"] = openAndSwap,
				["<M-S-q>"] = actions.add_to_qflist,
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
require("telescope").load_extension("ui-select")
require("telescope").load_extension("live_grep_args")

vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "find files" })
vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "git files" })
vim.keymap.set("n", "<leader>p", builtin.oldfiles, { desc = "recent files" })
vim.keymap.set("n", "<leader>Tr", builtin.registers, { desc = "registers" })
vim.keymap.set("n", "<leader>Tq", builtin.quickfixhistory, { desc = "qfhistory" })
vim.keymap.set("n", "<leader>s", function()
	require("telescope").extensions.live_grep_args.live_grep_args()
end, { desc = "live grep args" })
