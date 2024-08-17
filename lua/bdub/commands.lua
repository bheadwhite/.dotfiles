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

M.list_buffers = function()
	local function run_picker()
		pickers
			.new({
				initial_mode = "normal",
			}, {
				prompt_title = "Buffers",
				finder = finders.new_table({
					results = vim.fn.getbufinfo({
						buflisted = 1,
					}),
					entry_maker = function(entry)
						return {
							value = entry.bufnr,
							display = entry.name,
							ordinal = entry.bufnr .. " : " .. entry.name,
						}
					end,
				}),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(prompt_bufnr, map)
					local make_current_buffer = function()
						local selection = action_state.get_selected_entry()
						if selection then
							actions.close(prompt_bufnr)
							vim.cmd("buffer " .. selection.value)
						end
					end
					local delete_buffer = function()
						local selection = action_state.get_selected_entry()
						if selection then
							vim.api.nvim_buf_delete(selection.value, {
								force = true,
							})
							run_picker()
						end
					end

					map("i", "<CR>", make_current_buffer)
					map("n", "<CR>", make_current_buffer)
					map("n", "q", delete_buffer)
					return true
				end,
			})
			:find()
	end

	run_picker()
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

-- Function to open a floating window
local function open_floating_window()
	local buf = vim.api.nvim_create_buf(false, true) -- Create a new, unlisted, scratch buffer.
	local width = vim.o.columns
	local height = vim.o.lines

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.ceil(width * 0.8),
		height = math.ceil(height * 0.8),
		col = math.ceil(width * 0.1),
		row = math.ceil(height * 0.1),
		border = "rounded",
	})

	return buf, win
end

-- Function to gather parent references
local function gather_parents(buf)
	local params = vim.lsp.util.make_position_params()
	vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, _, _)
		if err or not result or vim.tbl_isempty(result) then
			return
		end

		vim.api.nvim_buf_set_lines(buf, 0, 1, false, { "Parents:" })
		for _, ref in ipairs(result) do
			local row = ref.range.start.line
			local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
		end
	end)
end

local function get_all_symbols()
	local parsers = require("nvim-treesitter.parsers")

	local bufnr = vim.api.nvim_get_current_buf()
	local parser = parsers.get_parser(bufnr)
	if not parser then
		print("Parser not found for current buffer")
		return
	end

	local tree = parser:parse()[1]
	local root = tree:root()

	-- Define a query to match all identifiers (symbols)
	-- local query = vim.treesitter.parse_query(
	-- 	"lua",
	-- 	[[
	--        (identifier) @symbol
	--    ]]
	-- )
	--
	-- local symbols = {}
	-- for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
	-- 	local symbol_name = vim.treesitter.query.get_node_text(node, bufnr)
	-- 	table.insert(symbols, symbol_name)
	-- end
	--
	-- return symbols
end

-- Function to print the symbols
local function print_symbols()
	local symbols = get_all_symbols()
	if symbols then
		print("Symbols found in the buffer:")
		for _, symbol in ipairs(symbols) do
			print(symbol)
		end
	end
end

-- Function to gather child symbols
local function gather_children(buf)
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "Children:" })

	-- print("gather children")
	local current_buf = vim.api.nvim_get_current_buf()
	local params = vim.lsp.util.make_position_params()

	vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(err, result)
		if err or not result or vim.tbl_isempty(result) then
			return
		end

		local function process_symbol(symbol)
			if symbol.kind == 6 then -- 6 is the LSP kind for constructors
				local row = symbol.range.start.line
				local line = vim.api.nvim_buf_get_lines(current_buf, row, row + 1, false)[1]
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
			end
			if symbol.children then
				for _, child in ipairs(symbol.children) do
					process_symbol(child)
				end
			end
		end

		for _, item in ipairs(result) do
			process_symbol(item)
		end
	end)
end

-- Main function to show references in a floating window
local function show_references()
	local buf, win = open_floating_window()
	-- gather_parents(buf)
	gather_children(buf)
	-- Optionally set the focus to the floating window
	vim.api.nvim_set_current_win(win)
end

-- Function to print all keys and their value types of a Lua object
function _G.printK(obj)
	if obj == nil then
		print("nil")
		return
	end

	if type(obj) == "function" then
		print("function")
		return
	end

	if type(obj) ~= "table" then
		print(obj)
		return
	end

	local keys = {}
	for key, value in pairs(obj) do
		table.insert(keys, {
			key = key,
			value_type = type(value),
		})
	end

	table.sort(keys, function(a, b)
		if a.value_type == b.value_type then
			return a.key < b.key
		else
			return a.value_type > b.value_type
		end
	end)

	print("Keys and their value types of the object:")
	for _, item in ipairs(keys) do
		print(item.key .. " (" .. item.value_type .. ")")
	end
end

-- Map the function to a key combination, e.g., <leader>rf
vim.keymap.set("n", "<leader>rf", print_symbols, {
	noremap = true,
	silent = true,
})

-- function M.buf_update_diagnostics()
-- 	local clients = vim.lsp.get_clients()
-- 	local buf = vim.api.nvim_get_current_buf()
--
-- 	for _, client in pairs(clients) do
-- 		local diagnostics = vim.lsp.diagnostic.get(buf, client.id)
-- 		vim.lsp.diagnostic.display(diagnostics, buf, client.id)
-- 	end
-- end
--
-- vim.api.nvim_exec(
-- 	[[
-- au CursorHold <buffer> lua require("bdub.commands").buf_update_diagnostics()
-- ]],
-- 	false
-- )

-- Map the function to a key combination, e.g., <leader>rf
-- vim.api.nvim_set_keymap("n", "<leader>rf", show_references, { noremap = true, silent = true })

return M
