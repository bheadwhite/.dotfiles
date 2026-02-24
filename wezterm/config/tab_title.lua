local colors = require("config.colors")
local M = {}

local working_directories = {
	"/code/playgrounds/",
	"/code/blackcat/",
	"/Projects/",
	"/code/",
}
local special_directories = { ".dotfiles" }
local home_directory = "/Users/brent.whitehead"

local function contains(str, substr)
	return string.find(str, substr) ~= nil
end

local function split_path_and_count(path)
	local count = 0
	for _ in string.gmatch(path, "[^/]+") do
		count = count + 1
	end
	return count
end

local function tab_title(tab_info)
	local title = tab_info.tab_title

	if title and #title > 0 then
		return title
	end

	-- Otherwise, use the title from the active pane
	return tab_info.active_pane.title
end

local function get_pwd(tab)
	local pane = tab.active_pane
	if pane and pane.current_working_dir then
		local cwd = pane.current_working_dir
		return tostring(cwd):match(".*/brent%.whitehead(/.*)")
	end
	return nil
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
	local is_nvim = contains(title, "Nvim")

	if is_nvim then
		local pwd = get_pwd(tab)
		local vimDisplay = title or ""

		-- Get working directory from title string
		local oil_path = title:match("%(oil://(.-)%)")
		local raw_path = title:match("%((.-)%)")
		local cwd = oil_path or raw_path

		if cwd and cwd:sub(1, 1) == "~" then
			cwd = cwd:gsub("^~", home_directory)
		end

		local project = nil

		if cwd and pwd then
			for _, working_dir in ipairs(working_directories) do
				if pwd:find(working_dir, 1, true) then
					local count = split_path_and_count(working_dir)

					local slug = working_dir:gsub("/$", ""):match("([^/]+)$")
					if count == 1 then
						local relative = pwd:sub(#working_dir + 1)
						local next_segment = relative:match("([^/]+)")
						if next_segment then
							project = next_segment
						else
							project = slug
						end
					elseif count == 2 then
						local relative = pwd:sub(#working_dir + 1)
						local next_segment = relative:match("([^/]+)")

						if slug and next_segment then
							project = slug .. "/" .. next_segment
						else
							project = slug
						end
					end

					break
				end
			end

			if not project then
				for _, special_dir in ipairs(special_directories) do
					if pwd:find(special_dir, 1, true) then
						local segments = {}
						for part in pwd:gmatch("[^/]+") do
							table.insert(segments, part)
						end
						if #segments >= 2 then
							project = segments[#segments - 1] .. "/" .. segments[#segments]
						else
							project = segments[#segments]
						end
						break
					end
				end
			end

			if not project then
				project = cwd
			end

			if project:sub(1, #home_directory) == home_directory then
				project = "~" .. project:sub(#home_directory + 1)
			end

			vimDisplay = project
			title = (oil_path and "  " or "☠  ") .. vimDisplay
		end
	end

	table.insert(result, {
		Text = title,
	})

	return result
end

return M
