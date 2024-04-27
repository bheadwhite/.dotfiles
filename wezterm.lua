-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
if wezterm.config_builder then
	-- help provide clearer error messages
	config = wezterm.config_builder()
end

config.font_size = 16
config.font = wezterm.font("Hack Nerd Font Mono")
-- config.disable_default_key_bindings = true
config.native_macos_fullscreen_mode = false
config.command_palette_font_size = 19
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.window_decorations = "RESIZE"
config.front_end = "OpenGL"
config.color_scheme = "3024 (base16)"
config.scrollback_lines = 999999

config.enable_kitty_keyboard = true
config.colors = {
	split = "#384b55",
}
config.inactive_pane_hsb = {
	hue = 0.9,
	saturation = 0.0,
	brightness = 1.0,
}

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end

	local currentDir = tab_info.active_pane.current_working_dir

	local found = string.find(currentDir, "Projects/")
	if found then
		local newTitle = string.gsub(tab_info.active_pane.title, ".*/(.*)$", "%1")
		return newTitle
	end

	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab_title(tab)

	wezterm.log_info("title: " .. title)

	if tab.is_active then
		return {
			{ Background = { Color = "#384b55" } },
			{ Text = " " .. title .. " " },
		}
	end

	return {
		{ Text = "" .. title .. " " },
	}
end)

config.keys = {
	{
		key = "w",
		mods = "CMD",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	{ key = "z", mods = "CMD", action = act.TogglePaneZoomState },
	{ key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
	{ key = "n", mods = "CMD", action = act.SpawnWindow },
	{
		key = "t",
		mods = "CMD",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({}) },
	{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({}) },
	{
		key = ",",
		mods = "CMD",
		action = act.ActivatePaneDirection("Next"),
	},
	{
		key = ".",
		mods = "CMD",
		action = act.ActivatePaneDirection("Prev"),
	},
	{
		key = "j",
		mods = "CMD|SHIFT",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CMD|SHIFT",
		action = act.ActivatePaneDirection("Up"),
	},
	{ key = "{", mods = "CMD|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "=", mods = "CMD", action = act.IncreaseFontSize },
	{ key = ",", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = ".", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "}", mods = "CMD|SHIFT", action = act.MoveTabRelative(1) },
	{ key = " ", mods = "CTRL|SHIFT", action = act.QuickSelect },
	{ key = "m", mods = "CMD", action = wezterm.action.ToggleFullScreen },
	{ key = " ", mods = "CMD|CTRL", action = act.CharSelect },
	-- { key = "c", mods = "CTRL", action = act({ SendKey = { key = "d", mods = "CTRL" } }) },
	{
		key = "f",
		mods = "CMD",
		action = act.Search({ CaseSensitiveString = "" }),
	},
	{
		key = "p",
		mods = "CMD",
		action = act.ActivateCommandPalette,
	},
	{
		key = "Backspace",
		mods = "ALT",
		action = act({ SendString = "\x17" }),
	},
	{
		key = "Backspace",
		mods = "CMD",
		action = act({ SendString = "\x15" }),
	},
	{
		key = "LeftArrow",
		mods = "CMD",
		action = act.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "RightArrow",
		mods = "CMD",
		action = act.AdjustPaneSize({ "Right", 5 }),
	},
	{
		key = "DownArrow",
		mods = "CMD",
		action = act.AdjustPaneSize({ "Down", 5 }),
	},
	{
		key = "UpArrow",
		mods = "CMD",
		action = act.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "h",
		mods = "CMD",
		action = { SendKey = { key = "Home" } },
	},
	{
		key = "l",
		mods = "CMD",
		action = { SendKey = { key = "End" } },
	},
}

-- and finally, return the configuration to wezterm
return config
