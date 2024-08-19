local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local function get_bookmarks()
	local files = vim.fn.sort(vim.fn["bm#all_files"]())
	local locations = {}

	local count = 1
	for _, file in ipairs(files) do
		local line_nrs = vim.fn.sort(vim.fn["bm#all_lines"](file), "bm#compare_lines")
		for _, line_nr in ipairs(line_nrs) do
			local bookmark = vim.fn["bm#get_bookmark_by_line"](file, line_nr)
			local content = bookmark["annotation"] ~= "" and bookmark["annotation"]
				or (bookmark["content"] ~= "" and bookmark["content"] or "empty line")
			table.insert(locations, { count, content, file, tonumber(line_nr), 0 })
		end
	end

	return locations
end

local function telescope_bookmarks(opts)
	opts = opts or {}
	local bookmarks = get_bookmarks()

	pickers
		.new({}, {
			prompt_title = "Bookmarks",
			initial_mode = "normal",
			finder = finders.new_table({
				results = bookmarks,
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
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.grep_previewer({}),
		})
		:find()
end

return {
	telescope_bookmarks = telescope_bookmarks,
}
