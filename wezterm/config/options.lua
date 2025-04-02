local colors = require("config.colors")
local wezterm = require("wezterm")

local window_frame = {
	border_left_width = "1cell",
	border_left_color = colors.everforestGreen,
	border_top_color = colors.bg1,
}

return {
	-- debug_key_events = true,
	font_size = 15,
	command_palette_font_size = 19,
	native_macos_fullscreen_mode = false,
	send_composed_key_when_left_alt_is_pressed = false,
	send_composed_key_when_right_alt_is_pressed = false,
	tab_max_width = 30,
	window_decorations = "RESIZE",
	front_end = "OpenGL",
	color_scheme = colors.color_scheme,
	enable_kitty_keyboard = true,
	foreground_text_hsb = {
		brightness = 1.8,
	},
	colors = {
		split = colors.purple,
		background = wezterm.color.parse(colors.bg0):lighten(0),
	},
	inactive_pane_hsb = {
		hue = 10,
		saturation = 4,
		brightness = 0.4,
	},
	color_schemes = {
		["dark"] = colors.dark,
		["dark_focus"] = colors.dark_focus,
	},
	window_frame = window_frame,
}
