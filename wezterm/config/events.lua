local wezterm = require("wezterm")
local act = wezterm.action
local nvim = require("config.nvim")
local colors = require("config.colors")
local options = require("config.options")

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
		-- print(title)
		print("hit")
		return title
	end

	-- Otherwise, use the title from the active pane
	-- in that tab
	-- return tab_info.active_pane.title
	return tab_info.active_pane.title
end

function M.moveNextPane(window, pane)
	window:perform_action(act.ActivatePaneDirection("Next"), pane)
end

function M.movePrevPane(window, pane)
	window:perform_action(act.ActivatePaneDirection("Prev"), pane)
end

function M.splitRight(window, pane)
	local action = nvim.wez_nvim_actions.split_right.wez
	if nvim.is_nvim_process(window) then
		action = nvim.wez_nvim_actions.split_right.nvim
	end

	window:perform_action(action, pane)
end

function M.zoomToggle(window, pane)
	local action = nvim.wez_nvim_actions.zoom_toggle.wez
	if nvim.is_nvim_process(window) then
		action = nvim.wez_nvim_actions.zoom_toggle.nvim
	end

	window:perform_action(action, pane)
end

function M.splitDown(window, pane)
	local action = nvim.wez_nvim_actions.split_down.wez
	if nvim.is_nvim_process(window) then
		action = nvim.wez_nvim_actions.split_down.nvim
	end

	window:perform_action(action, pane)
end

function M.apply_color_scheme(window)
	local focused = window:is_focused()
	local overrides = window:get_config_overrides() or {}
	overrides.window_frame = options.window_frame

	if focused then
		options.window_frame.border_left_color = options.everforestGreen
	else
		options.window_frame.border_left_color = colors.red
	end

	window:set_config_overrides(overrides)
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

	if is_nvim then
		local vimDisplay = title or ""
		-- local projectPath = title:match("%(~/Projects(.-)%)")
		local project = title:match("/Projects/([^/%)]+)") or title:match("/code/([^/%)]+)")

		if project then
			vimDisplay = project or ""
		else
			-- grab the inside text of the ()
			vimDisplay = title:match("%((.-)%)") or title
		end
		title = "☠  " .. vimDisplay
	end

	table.insert(result, {
		Text = title,
	})

	return result
end

return M
