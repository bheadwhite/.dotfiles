local colors = require("config.colors")
local M = {}

local working_directories = {
	{ path = "/code/playgrounds/", depth = 1 },
	{ path = "/code/blackcat/", depth = 1 },
	{ path = "/projects/", depth = 2 },
	{ path = "/code/extra/", depth = 1 },
	{ path = "/code/", depth = 1 },
}
local special_directories = { ".dotfiles" }
local home_directory = "/Users/brent.whitehead"

local shell_processes = {
	zsh = true,
	bash = true,
	fish = true,
	sh = true,
	dash = true,
	tmux = true,
	["tmux: server"] = true,
}

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

local function get_foreground_program(tab)
	local pane = tab.active_pane
	if not pane or not pane.foreground_process_name or pane.foreground_process_name == "" then
		return nil
	end
	local name = pane.foreground_process_name:match("([^/\\]+)$")
	if not name or shell_processes[name] then
		return nil
	end
	if name == "nvim" or name == "vim" then
		return nil
	end
	return name
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
	local pwd = get_pwd(tab)
	local program = not is_nvim and get_foreground_program(tab) or nil

	if pwd then
		local project = nil

		for _, entry in ipairs(working_directories) do
			if pwd:find(entry.path, 1, true) then
				local slug = entry.path:gsub("/$", ""):match("([^/]+)$")
				local relative = pwd:sub(#entry.path + 1)
				local segments = {}
				for part in relative:gmatch("[^/]+") do
					table.insert(segments, part)
					if #segments >= entry.depth then
						break
					end
				end
				if #segments > 0 then
					project = table.concat(segments, " - ")
				else
					project = slug
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

		if project then
			if project:sub(1, #home_directory) == home_directory then
				project = "~" .. project:sub(#home_directory + 1)
			end

			if is_nvim then
				title = "☠  " .. project
			elseif program then
				title = program .. " - " .. project
			else
				title = project
			end
		end
	end

	if program and not contains(title, program) then
		title = program .. " - " .. title
	end

	table.insert(result, {
		Text = title,
	})

	return result
end

return M
