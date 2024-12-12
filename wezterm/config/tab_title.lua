local colors = require("config.colors")
local M = {}

local function contains(str, substr)
	return string.find(str, substr) ~= nil
end

local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- -- if the tab title is explicitly set, take that
	-- if not tab_info.is_active then
	-- 	print(tab_info)
	-- end

	if title and #title > 0 then
		return title
	end

	-- Otherwise, use the title from the active pane
	-- in that tab
	-- return tab_info.active_pane.title
	return tab_info.active_pane.title
end

function M.formatTabTitle(tab, tabs, panes, config, hover, max_width)
	local result = {
		{ Foreground = { Color = "#ffffff" } },
	}

	if tab.is_active then
		table.insert(result, {
			Background = {
				Color = colors.bg5,
			},
		})
	end

	local title = tab_title(tab)
	local is_nvim = contains(title, "NVIM")

	-----------------

	if is_nvim then
		-- (oil:///Users/brent.whitehead/Projects/tcn) - NVIM
		local vimDisplay = title or ""
		local working_directories = { "/code/playgrounds/", "/Projects/", "/code/" } -- if found will return child directory name
		local special_directories = { ".dotfiles" } -- if found will return directory name
		local home_directory = "/Users/brent.whitehead"

		local project = nil

		-- Check if the title contains "oil" within parentheses
		local oil_match = title:match("%(oil://.-%)")
		if oil_match then
			-- Extract the text within the parentheses
			title = oil_match:match("%((.-)%)"):gsub("oil://", "")
		end

		for _, working_dir in ipairs(working_directories) do
			project = title:match(working_dir .. "([^/%)]+)")
			if project then
				break
			end
		end

		if not project then
			for _, special_dir in ipairs(special_directories) do
				project = title:match(special_dir)
				if project then
					break
				end
			end
		end

		if project then
			vimDisplay = project
		else
			-- grab the inside text of the ()
			vimDisplay = title:match("%((.-)%)") or title
		end

		-- Replace home directory with "~"
		if vimDisplay:sub(1, #home_directory) == home_directory then
			vimDisplay = "~" .. vimDisplay:sub(#home_directory + 1)
		end

		if oil_match then
			title = "  " .. vimDisplay
		else
			title = "☠  " .. vimDisplay
		end
	end

	----------

	table.insert(result, {
		Text = title,
	})

	return result
end

return M
