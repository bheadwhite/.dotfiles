local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local nvim = "/Users/brent.whitehead/code/neovim/build/bin/nvim"

local M = {}
M.wez_nvim_actions = {
	-- Plain F13–F16 (no modifier) so they encode via standard xterm sequences and
	-- reach nvim without the kitty keyboard protocol (see config/init.lua). These
	-- F-keys are otherwise unused, so the bare key is unambiguous.
	zoom_toggle = {
		wez = act.TogglePaneZoomState,
		nvim = act.SendKey({ key = "F13" }),
	},
	split_right = {
		wez = act.SplitHorizontal({}),
		nvim = act.SendKey({ key = "F14" }),
	},
	split_down = {
		wez = act.SplitVertical({}),
		nvim = act.SendKey({ key = "F15" }),
	},
	-- Cmd+V: in nvim, route to <F16> so the editor can decide between a normal
	-- text paste and attaching a clipboard screenshot. Elsewhere, paste as usual.
	smart_paste = {
		wez = act.PasteFrom("Clipboard"),
		nvim = act.SendKey({ key = "F16" }),
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
