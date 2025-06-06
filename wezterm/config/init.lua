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

config.font_size = 15
config.command_palette_font_size = 19
config.native_macos_fullscreen_mode = false
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.tab_max_width = 30
config.window_decorations = "RESIZE"
config.front_end = "OpenGL"
config.color_scheme = colors.color_scheme
config.enable_kitty_keyboard = true
config.foreground_text_hsb = {
	brightness = 1.8,
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
