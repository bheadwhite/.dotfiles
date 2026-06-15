local wezterm = require("wezterm")
local act = wezterm.action
local nvim = require("config.nvim")
local colors = require("config.colors")
local options = require("config.init")

local M = {}

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

function M.smartPaste(window, pane)
	local action = nvim.wez_nvim_actions.smart_paste.wez
	if nvim.is_nvim_process(window) then
		action = nvim.wez_nvim_actions.smart_paste.nvim
	end

	window:perform_action(action, pane)
end

local themes = {
	default = options.color_scheme,
	aqua = "aqua",
	purple = "purple",
	blue = "blue",
	orange = "orange",
}

function M.setRightStatus(window, pane)
	-- "Wed Mar 3 08:14"
	local date = wezterm.strftime("%a %b %-d %H:%M ")

	local elements = {}

	-- confirm-mode banner: shown while the confirm_close key table is armed.
	-- Re-fires automatically because wezterm emits update-right-status on key
	-- table push/pop. cmd+w again (or y) closes; Esc / any other key cancels.
	if window:active_key_table() == "confirm_close" then
		table.insert(elements, { Background = { Color = colors.red } })
		table.insert(elements, { Foreground = { Color = colors.bg_dim } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = "  close pane? cmd+w / y · esc  " })
		table.insert(elements, "ResetAttributes")
		table.insert(elements, { Text = " " })
	end

	table.insert(elements, { Text = date })

	window:set_right_status(wezterm.format(elements))
end

function M.toggle_background(window, pane)
	local focused = window:is_focused()
	if not focused then
		return
	end
	local overrides = window:get_config_overrides() or {}

	if not overrides.window_frame then
		overrides.window_frame = {}
	end

	if overrides.color_scheme == themes.default then
		overrides.color_scheme = themes.aqua
	elseif overrides.color_scheme == themes.aqua then
		overrides.color_scheme = themes.purple
	elseif overrides.color_scheme == themes.purple then
		overrides.color_scheme = themes.blue
	elseif overrides.color_scheme == themes.blue then
		overrides.color_scheme = themes.orange
	else
		overrides.color_scheme = themes.default
	end

	window:set_config_overrides(overrides)
end

function M.splitDown(window, pane)
	local action = nvim.wez_nvim_actions.split_down.wez
	if nvim.is_nvim_process(window) then
		action = nvim.wez_nvim_actions.split_down.nvim
	end

	window:perform_action(action, pane)
end

function getWindowColor(color_theme)
	if not color_theme then
		return "#ffffff"
	end

	if color_theme == themes.default then
		return "#ffffff"
	elseif color_theme == themes.aqua then
		return colors.aqua
	elseif color_theme == themes.purple then
		return colors.purple
	elseif color_theme == themes.blue then
		return colors.blue
	elseif color_theme == themes.orange then
		return colors.orange
	end
end

function M.apply_color_scheme(window)
	local focused = window:is_focused()
	local overrides = window:get_config_overrides() or {}

	local border_color
	if focused then
		border_color = getWindowColor(overrides.color_scheme)
	else
		border_color = options.everforestGreen
	end

	-- Build a fresh window_frame table to avoid mutating shared config state
	local new_frame = {}
	for k, v in pairs(options.window_frame) do
		new_frame[k] = v
	end
	new_frame.border_top_color = border_color
	new_frame.border_left_color = border_color
	new_frame.border_bottom_color = border_color
	new_frame.border_right_color = border_color

	overrides.window_frame = new_frame
	window:set_config_overrides(overrides)
end

return M
