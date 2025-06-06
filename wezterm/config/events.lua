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

	window:set_right_status(wezterm.format({
		{ Text = date },
	}))
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

	options.window_frame.border_left_color = getWindowColor(overrides.color_scheme)
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
	overrides.window_frame = options.window_frame

	if focused then
		options.window_frame.border_top_color = getWindowColor(overrides.color_scheme)
		options.window_frame.border_left_color = getWindowColor(overrides.color_scheme)
		options.window_frame.border_bottom_color = getWindowColor(overrides.color_scheme)
		options.window_frame.border_right_color = getWindowColor(overrides.color_scheme)
	else
		options.window_frame.border_top_color = options.everforestGreen
		options.window_frame.border_left_color = options.everforestGreen
		options.window_frame.border_bottom_color = options.everforestGreen
		options.window_frame.border_right_color = options.everforestGreen
	end

	window:set_config_overrides(overrides)
end

return M
