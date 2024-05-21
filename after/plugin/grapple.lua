local grapple = require("grapple")

grapple.setup({
	scope = "git_branch",
	name_pos = "start",
	win_opts = {
		width = 0.9,
		height = 0.8,
		relative = "editor",
		title_pos = "center",
		focusable = true,
		title = "hello world",
	},
})

local function getName()
	local name = vim.fn.input("a man needs a name: ")
	if name == nil or name == "" then
		return nil
	end

	return name
end

vim.keymap.set("n", "<leader>a", function()
	local name = getName()
	grapple.tag({ name = name })
end, { silent = true, desc = "grapple tag" })
vim.keymap.set("n", "<leader>A", function()
	local name = getName()
	grapple.tag({ name = name, scope = "global" })
end, { silent = true, desc = "grapple global tag" })

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

local function delete_tag(prompt_bufnr, opts)
	local action_state = require("telescope.actions.state")
	local selection = action_state.get_selected_entry()

	grapple.untag({ path = selection.filename })

	local current_picker = action_state.get_current_picker(prompt_bufnr)
	current_picker:refresh(create_finder(opts), { reset_prompt = true })
end

local function telescope_grapple_tags(grapple_opts)
	local conf = require("telescope.config").values

	require("telescope.pickers")
		.new(grapple_opts or {}, {
			finder = create_finder(grapple_opts),
			previewer = conf.grep_previewer({}),
			sorter = conf.file_sorter({}),
			results_title = "Grapple Tags",
			prompt_title = "Find Grappling Tags",
			layout_strategy = "flex",
			attach_mappings = function(_, map)
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

vim.keymap.set("n", "<C-S-M-p>", function()
	telescope_grapple_tags({
		scope = "global",
	})
end, { silent = true, desc = "toggle global tags" })

vim.keymap.set("n", "<C-M-p>", function()
	telescope_grapple_tags()
end, { silent = true, desc = "toggle tags" })
vim.keymap.set("n", "<C-S-M-[>", function()
	grapple.toggle_tags({
		scope = "global",
	})
end, { silent = true, desc = "toggle global tags" })

vim.keymap.set("n", "<C-M-[>", function()
	grapple.toggle_tags()
end, { silent = true, desc = "toggle tags" })
