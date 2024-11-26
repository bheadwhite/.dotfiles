local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local nvim = "/Users/brent.whitehead/code/neovim/build/bin/nvim"

local M = {}
M.wez_nvim_actions = {
	zoom_toggle = {
		wez = act.TogglePaneZoomState,
		nvim = act.SendKey({ key = "F13", mods = "CTRL" }),
	},
	split_right = {
		wez = act.SplitHorizontal({}),
		nvim = act.SendKey({ key = "F14", mods = "CTRL" }),
	},
	split_down = {
		wez = act.SplitVertical({}),
		nvim = act.SendKey({ key = "F15", mods = "CTRL" }),
	},
}

function M.is_nvim_process(window)
	local current_process = mux.get_window(window:window_id()):active_pane():get_foreground_process_name()
	return current_process == nvim
end

return M
