local wezterm = require("wezterm")
local act = wezterm.action
local colors = require("config.colors")
local color_pointer = require("config.color_pointer")

local config = {}
local window_frame = {
	border_top_height = ".1cell",
	border_bottom_height = ".1cell",
	border_left_color = colors.everforestGreen,
	border_top_color = colors.bg1,
	border_bottom_color = colors.bg1,
	border_left_width = ".3cell",
	border_right_width = ".3cell",
}

-- ── Copy/paste model: explicit, predictable ──────────────────────────────────
-- The clipboard ONLY changes when you press ⌘C. Selecting text just highlights
-- it (no auto-copy), so you never have to wonder whether something was copied.
--   • ⌘C  → copy selection (WezTerm macOS default)
--   • ⌘⇧C → copy mode (keyboard select/yank; see config/keys.lua)
-- Inside TUIs that capture the mouse (Claude Code, nvim, pagers), hold SHIFT
-- while dragging to highlight — SHIFT is the bypass-mouse-reporting modifier.
config.bypass_mouse_reporting_modifiers = "SHIFT"
config.mouse_bindings = {
	-- Finish a selection WITHOUT copying. The highlight stays put for ⌘C.
	-- (Covers single/double/triple click, plus SHIFT-drag inside TUIs.)
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "NONE", action = act.Nop },
	{ event = { Up = { streak = 2, button = "Left" } }, mods = "NONE", action = act.Nop },
	{ event = { Up = { streak = 3, button = "Left" } }, mods = "NONE", action = act.Nop },
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "SHIFT", action = act.Nop },
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "ALT", action = act.Nop }, -- block-select, no auto-copy

	-- ⌘-click opens the link under the cursor (works even when an app is
	-- grabbing the mouse). The Down→Nop stops ⌘-press from moving the cursor.
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "CMD", action = act.OpenLinkAtMouseCursor, mouse_reporting = true },
	{ event = { Down = { streak = 1, button = "Left" } }, mods = "CMD", action = act.Nop, mouse_reporting = true },
}

config.debug_key_events = true
config.font_size = 15
config.command_palette_font_size = 19
config.native_macos_fullscreen_mode = false
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.tab_max_width = 30
config.window_decorations = "RESIZE"
config.front_end = "WebGpu"
config.color_scheme = colors.color_scheme
-- Keep the kitty keyboard protocol OFF: enabling it makes wezterm re-encode Esc
-- as a CSI-u sequence (\x1b[27u), which breaks the <Esc> mapping in nvim.
-- cmd+z/cmd+d/cmd+v are routed into nvim as PLAIN F13/F14/F15/F16 (see
-- config/nvim.lua) — unmodified F13–F16 use standard xterm sequences, so they
-- reach nvim WITHOUT needing this protocol.
config.enable_kitty_keyboard = false
config.enable_kitty_graphics = false -- Disable graphics to reduce key sequence conflicts
-- Foreground tuning for the ACTIVE pane, left at identity on purpose: colors
-- render exactly as the scheme and the running app intend them.
-- This filter used to sit at brightness = 1.8, which flattened syntax
-- highlighting — brightness is a multiplier that CLIPS, so bright colors slam
-- into the top of each RGB channel and all converge on white. Saturation is the
-- safer knob (it separates hues without blowing them out), but it recolors
-- app-chosen colors too, which reads as "off" in TUIs that ship their own
-- palette. Tune from 1.0 in small steps if you want more punch.
config.foreground_text_hsb = {
	saturation = 1.0,
	brightness = 1.0,
}
config.colors = color_pointer
-- Inactive panes: DIM ONLY. All three fields are multipliers, and `hue`
-- multiplies the hue ANGLE, so anything but 1.0 rotates the color wheel --
-- hue = 10 was turning red ERROR text green. saturation = 4 then clamped every
-- color to full chroma, flattening what was left. Keep hue and saturation at
-- 1.0 and turn brightness down alone; that is the only knob that dims without
-- recoloring.
config.inactive_pane_hsb = {
	hue = 1.0,
	saturation = 1.0,
	brightness = 0.5,
}
config.color_schemes = {
	["dark"] = {},
	["aqua"] = {},
	["orange"] = {},
	["purple"] = {},
	["blue"] = {},
	["dark_focus"] = {},
}
config.window_frame = window_frame

return config
