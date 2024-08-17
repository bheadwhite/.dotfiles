local grapple = require("grapple")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

local scopes = { "git_branch", "cwd", "global" }
local active_index = 1
local active_grapple_win_id = ""

local M = {}

local function handle_grapple_win_sync()
	if active_grapple_win_id ~= "" then
		local prompt_bufnr = vim.api.nvim_win_get_buf(active_grapple_win_id)
		local opts = { scope = M.get_active_scope() }
		actions.close(prompt_bufnr)

		open_grapple_telescope_picker(opts)
	end
end

local function getNameFromInput()
	local name = vim.fn.input(M.get_active_scope() .. " - a man needs a name: ")
	if name == nil or name == "" then
		return nil
	end

	return name
end

vim.api.nvim_create_autocmd("WinClosed", {
	callback = function(event)
		local win_id = tonumber(event.match)
		if win_id == active_grapple_win_id then
			active_grapple_win_id = ""
		end
	end,
})

local function activate_scope()
	grapple.use_scope(M.get_active_scope())
	handle_grapple_win_sync()
end

function M.get_active_scope()
	return scopes[active_index]
end

grapple.setup()

local function create_finder(opts)
	local tags, err = grapple.tags(opts)
	if not tags then
		---@diagnostic disable-next-line: param-type-mismatch
		return vim.notify(err, vim.log.levels.ERROR)
	end

	local utils = require("telescope.utils")

	local results = {}
	for i = #tags, 1, -1 do
		local tag = tags[i]
		---@class grapple.telescope.result

		local result = {
			i,
			tag.name or utils.transform_path({ path_display = {} }, tag.path),
			tag.path,
			(tag.cursor or { 1, 0 })[1],
			(tag.cursor or { 1, 0 })[2],
		}

		table.insert(results, result)
	end

	return require("telescope.finders").new_table({
		results = results,
		---@param result grapple.telescope.result
		entry_maker = function(result)
			local display = result[2]
			local filename = result[3]
			local lnum = result[4]

			local entry = {
				value = result,
				ordinal = filename,
				display = display,
				filename = filename,
				lnum = lnum,
			}

			return entry
		end,
	})
end

function delete_tag(prompt_bufnr, opts)
	local selection = action_state.get_selected_entry()

	grapple.untag({ path = selection.filename })

	local current_picker = action_state.get_current_picker(prompt_bufnr)
	current_picker:refresh(create_finder(opts), { reset_prompt = true })
end

function open_grapple_telescope_picker(grapple_opts)
	local conf = require("telescope.config").values

	require("telescope.pickers")
		.new(grapple_opts or {}, {
			finder = create_finder(grapple_opts),
			sorter = conf.file_sorter({}),
			initial_mode = "normal",
			results_title = "[ " .. active_index .. " ] - " .. M.get_active_scope(),
			prompt_title = "grapple",
			layout_strategy = "flex",
			attach_mappings = function(_, map)
				active_grapple_win_id = vim.api.nvim_get_current_win()

				map("i", "<C-X>", function(bufnr)
					delete_tag(bufnr, grapple_opts)
				end)
				map("n", "d", function(bufnr)
					delete_tag(bufnr, grapple_opts)
				end)
				return true
			end,
		})
		:find()
end

vim.keymap.set("n", "<leader>a", function()
	local name = getNameFromInput()
	grapple.tag({ name = name, scope = M.get_active_scope() })
	vim.cmd("normal! mf")
end, { silent = true, desc = "tag file in current scope" })

-- vim.keymap.set("n", "<C-S-M-p>", function()
-- 	grapple.toggle_tags({ scope = M.get_active_scope() })
-- end, { silent = true, desc = "toggle active tags in grapple window" })

vim.keymap.set("n", "<C-q>", function()
	open_grapple_telescope_picker({ scope = M.get_active_scope() })
end, { silent = true, desc = "telescope tags" })

vim.keymap.set("n", "<C-M-1>", function()
	active_index = 1
	activate_scope()
end, { silent = true, desc = "activate index 1" })
vim.keymap.set("n", "<C-M-2>", function()
	active_index = 2
	activate_scope()
end, { silent = true, desc = "activeate index 2" })
vim.keymap.set("n", "<C-M-3>", function()
	active_index = 3
	activate_scope()
end, { silent = true, desc = "activate index 3" })

return M
