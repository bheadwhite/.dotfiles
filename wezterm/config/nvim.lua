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
	-- Cmd+V: in nvim, route to <C-F16> so the editor can decide between a normal
	-- text paste and attaching a clipboard screenshot. Elsewhere, paste as usual.
	smart_paste = {
		wez = act.PasteFrom("Clipboard"),
		nvim = act.SendKey({ key = "F16", mods = "CTRL" }),
	},
}

-- True when the focused pane is running nvim. Matched by binary basename so it
-- works no matter which nvim is on PATH (source build, /usr/local/bin/nvim, …) —
-- the exact `nvim` path above is just one accepted value, not a requirement.
function M.is_nvim_process(window)
	local proc = mux.get_window(window:window_id()):active_pane():get_foreground_process_name() or ""
	return proc == nvim or proc:gsub("[/\\]", "/"):gsub(".*/", "") == "nvim"
end

return M
