local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local dropdown_theme =
	require("telescope.themes").get_dropdown({ previewer = false, layout_config = {
		width = 800,
	} })

local function get_vim_path()
	local file_path = vim.fn.expand("%:.")
	if file_path == "" then
		vim.cmd("echoerr 'No file path'")
	end

	return file_path
end

local function find_directories()
	return finders.new_oneshot_job({ "fd", "--type", "d" })
end

local function get_dir_results_from_picker(picker)
	local selected_entry = action_state.get_selected_entry()
	local selected = { selected_entry[1] }

	for _, entry in ipairs(picker:get_multi_selection()) do
		local text = entry.text
		if not text then
			if type(entry.value) == "table" then
				text = entry.value.text
			else
				text = entry.value
			end
		end

		table.insert(selected, text)
	end

	return selected
end

local function find_files_attach_mapping(prompt_bufnr)
	actions.select_default:replace(function()
		local picker = action_state.get_current_picker(prompt_bufnr)
		local dir_results = get_dir_results_from_picker(picker)

		actions.close(prompt_bufnr)

		require("telescope.builtin").find_files({
			prompt_title = "Find files in dirs",
			search_dirs = dir_results,
		})
	end)

	return true
end

local function grep_files_attach_mapping(prompt_bufnr)
	actions.select_default:replace(function()
		local picker = action_state.get_current_picker(prompt_bufnr)
		local dir_results = get_dir_results_from_picker(picker)

		actions.close(prompt_bufnr)

		require("telescope.builtin").live_grep({
			prompt_title = "live grep within dirs...",
			search_dirs = dir_results,
		})
	end)

	return true
end

local M = {}

M.copy_operator_file_path = function(file_path)
	if string.find(file_path, "commons/ui") then
		file_path = file_path:gsub("^(commons/)ui/(.*).tsx?$", "@neo/%1%2")
		vim.fn.setreg("+", file_path)
		print("copied " .. file_path)
	elseif string.find(file_path, "ui/operator/src") then
		file_path = file_path:gsub("^ui(.*).tsx?$", "@neo%1")
		vim.fn.setreg("+", file_path)
		print("copied " .. file_path)
	else
		vim.fn.setreg("+", file_path)
		print("copied " .. file_path)
	end
end

M.copy_file_path = function()
	local file_path = get_vim_path()
	M.copy_operator_file_path(file_path)
end

M.find_files_within_directories = function()
	local options = {
		prompt_title = "Select Directories For File Search",
		sorter = conf.generic_sorter(),
		finder = find_directories(),
		attach_mappings = find_files_attach_mapping,
	}

	pickers.new(dropdown_theme, options):find()
end

M.grep_string_within_directories = function()
	local options = {
		prompt_title = "Select Dirs to Search",
		sorter = conf.generic_sorter(),
		finder = find_directories(),
		attach_mappings = grep_files_attach_mapping,
	}

	pickers.new(dropdown_theme, options):find()
end

return M
