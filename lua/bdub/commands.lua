local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

local dropdown_theme = require("telescope.themes").get_dropdown({
	previewer = false,
	layout_config = {
		width = 800,
	},
})

local function get_vim_path()
	local file_path = vim.fn.expand("%:.")
	if file_path == "" then
		vim.cmd("echoerr 'No file path'")
	end

	return file_path
end

M.set_vim_title = function()
	local cwd = vim.fn.getcwd()
	local dir_name = cwd:match("^.+/(.+)$")

	vim.cmd("set titlestring=" .. dir_name)
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

M.format_jq = function()
	vim.cmd("%!jq .")
end

vim.api.nvim_create_user_command("ApplyLastSubstitute", function()
	-- Get the last substitute command from the command history
	local last_cmd = vim.fn.histget(":", -2)
	print(last_cmd)

	-- Extract the substitute command if it exists
	local substitute_cmd = last_cmd:match("^%%?s/.*$")

	if not substitute_cmd then
		print("No substitute command found in history.")
		return
	end

	local cdo_cmd = "silent! noau cdo " .. substitute_cmd .. " | update"

	-- Iterate over the quickfix list and apply the substitute command
	vim.cmd(cdo_cmd)

	print("Applied substitute command to all quickfix list items.")
end, {})

-- -- Function to run a shell command and return the output
-- local function run_command(cmd)
-- 	local handle = io.popen(cmd)
-- 	if not handle then
-- 		return ""
-- 	end
--
-- 	local result = handle:read("*a")
-- 	handle:close()
-- 	return result
-- end
--
-- -- Function to get the list of changed files in the working directory
-- local function get_changed_files()
-- 	local output = run_command("git status --porcelain")
-- 	local files = {}
-- 	for line in output:gmatch("[^\r\n]+") do
-- 		local file = line:match(".. (.+)")
-- 		if file then
-- 			table.insert(files, file)
-- 		end
-- 	end
-- 	return files
-- end
--
-- -- Function to populate the quickfix list
-- local function populate_quickfix_list(files)
-- 	local qf_list = {}
-- 	for _, file in ipairs(files) do
-- 		table.insert(qf_list, { filename = file })
-- 	end
-- 	vim.fn.setqflist(qf_list, "r")
-- 	vim.cmd("copen")
-- end
--
-- -- Main function
-- local function populate_qf_list_with_changed_files()
-- 	local changed_files = get_changed_files()
-- 	if #changed_files > 0 then
-- 		populate_quickfix_list(changed_files)
-- 	else
-- 		print("No changes in the working directory.")
-- 	end
-- end
--
-- vim.keymap.set("n", "<leader>gl", populate_qf_list_with_changed_files, { noremap = true, silent = true })

return M
