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

-- config.mouse_bindings = {
-- 	{
-- 		event = { Down = { streak = 1, button = "Right" } },
-- 		mods = "NONE",
-- 		action = wezterm.action_callback(function(window, pane)
-- 			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
-- 			if has_selection then
-- 				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
-- 				window:perform_action(act.ClearSelection, pane)
-- 			else
-- 				window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
-- 			end
-- 		end),
-- 	},
-- }

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
config.inactive_pane_hsb = {
	hue = 10,
	saturation = 4,
	brightness = 0.4,
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
