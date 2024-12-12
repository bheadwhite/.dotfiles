local wezterm = require("wezterm")
local act = wezterm.action
local nvim = require("config.nvim")
local colors = require("config.colors")
local options = require("config.options")

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

return M
