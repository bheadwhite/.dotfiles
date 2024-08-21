local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local textBrightness = 1.8
local fontSize = 16

local colors = {
	bg_dim = "#1e2326",
	bg0 = "#272e33",
	bg1 = "#2e383c",
	bg2 = "#374145",
	bg3 = "#414b50",
	bg4 = "#495156",
	bg5 = "#4f5b58",
	bg_red = "#4c3743",
	bg_visual = "#493b40",
	bg_yellow = "#45443c",
	bg_green = "#3c4841",
	bg_blue = "#384b55",
	red = "#e67e80",
	orange = "#e69875",
	yellow = "#dbbc7f",
	green = "#a7c080",
	blue = "#7fbbb3",
	aqua = "#83c092",
	purple = "#d699b6",
	fg = "#d3c6aa",
	statusline1 = "#a7c080",
	statusline2 = "#d3c6aa",
	statusline3 = "#e67e80",
	gray0 = "#7a8478",
	gray1 = "#859289",
	gray2 = "#9da9a0",
}
-- Pull in the wezterm API

-- This table will hold the configuration.
local config = {}

local wez_nvim_actions = {
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

-- { key = "d", mods = "CMD", action = act.SplitHorizontal({}) },
-- { key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({}) },

local nvim = "/Users/brent.whitehead/code/neovim/build/bin/nvim"
local function is_nvim_process(window)
	local current_process = mux.get_window(window:window_id()):active_pane():get_foreground_process_name()
	print(current_process)
	return current_process == nvim
end

wezterm.on("move-next", function(window, pane)
	window:perform_action(act.ActivatePaneDirection("Next"), pane)
end)

wezterm.on("move-prev", function(window, pane)
	window:perform_action(act.ActivatePaneDirection("Prev"), pane)
end)

wezterm.on("zoom-toggle", function(window, pane)
	action = wez_nvim_actions.zoom_toggle.wez
	if is_nvim_process(window) then
		action = wez_nvim_actions.zoom_toggle.nvim
	end
	window:perform_action(action, pane)
end)

wezterm.on("split-right", function(window, pane)
	action = wez_nvim_actions.split_right.wez
	if is_nvim_process(window) then
		action = wez_nvim_actions.split_right.nvim
	end
	window:perform_action(action, pane)
end)

wezterm.on("split-down", function(window, pane)
	action = wez_nvim_actions.split_down.wez
	if is_nvim_process(window) then
		action = wez_nvim_actions.split_down.nvim
	end
	window:perform_action(action, pane)
end)

wezterm.on("close-pane", function(window, pane)
	print(pane)

	-- window:perform_action(act.ActivatePaneDirection("Prev"), pane)
	--  window:perform_action(act.CloseCurrentPane({confirm = true}), pane)
end)

-- In newer versions of wezterm, use the config_builder which will
if wezterm.config_builder then
	-- help provide clearer error messages
	config = wezterm.config_builder()
end

local color_scheme = "DjangoSmooth"
local dark_focus = wezterm.color.get_builtin_schemes()[color_scheme]
local dark = wezterm.color.get_builtin_schemes()[color_scheme]
dark.background = wezterm.color.parse("white"):darken(0.5)
local everforestGreen = dark_focus.background
local window_frame = {
	border_left_width = "1cell",
	border_left_color = everforestGreen,
}

config.color_schemes = {
	["dark"] = dark,
	["dark_focus"] = dark_focus,
}

config.font_size = fontSize
config.color_scheme = color_scheme
config.native_macos_fullscreen_mode = false
config.command_palette_font_size = 19
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.window_decorations = "RESIZE"
config.front_end = "OpenGL"
config.color_scheme = color_scheme
-- config.scrollback_lines = 999999

config.enable_kitty_keyboard = true
config.foreground_text_hsb = {
	brightness = textBrightness,
}

config.colors = {
	split = colors.purple,
	background = wezterm.color.parse(colors.bg0):lighten(0),
}
config.window_frame = window_frame
config.inactive_pane_hsb = {
	hue = 2.3,
	saturation = 1,
	brightness = 1,
}

function apply_color_scheme(window)
	local focused = window:is_focused()
	local overrides = window:get_config_overrides() or {}
	overrides.window_frame = window_frame

	if focused then
		set_focused_window_frame()
	else
		set_unfocused_window_frame()
	end

	window:set_config_overrides(overrides)
end

function set_unfocused_window_frame()
	window_frame.border_top_color = colors.red
	window_frame.border_left_color = colors.red
end

function set_focused_window_frame()
	window_frame.border_top_color = everforestGreen
	window_frame.border_left_color = everforestGreen
end

wezterm.on("window-config-reloaded", function(window, pane)
	apply_color_scheme(window)
end)

wezterm.on("window-focus-changed", function(window, pane)
	apply_color_scheme(window)
end)

local function get_current_working_dir(tab)
	local current_dir = tab.active_pane.current_working_dir.path
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

	return current_dir == HOME_DIR and "." or string.gsub(current_dir, "(.*[/\\])(.*)", "%2")
end

function appearance_color_scheme(focused)
	local scheme = "light"

	if wezterm.gui then
		local appearance = wezterm.gui.get_appearance()
		if appearance:find("Dark") then
			scheme = "dark"
		end
	end

	if focused then
		return scheme .. "_focus"
	end

	return scheme
end

function contains(str, substr)
	return string.find(str, substr) ~= nil
end

function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local result = {}

	if tab.is_active then
		table.insert(result, {
			Background = {
				Color = dark_focus.background,
			},
		})
	end

	local title = tab_title(tab)
	local is_nvim = contains(title, "NVIM")

	if is_nvim then
		local vimDisplay = title
		local projectPath = title:match("%(~/Projects/(.-)%)")
		if projectPath then
			local project = projectPath:match("([^/]+)/")
			vimDisplay = project
		end
		title = "☠  " .. vimDisplay
	end

	table.insert(result, {
		Text = title,
	})

	return result
end)

config.keys = {
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action({ CloseCurrentPane = { confirm = true } }),
	},
	{
		key = "z",
		mods = "CMD",
		action = wezterm.action({ EmitEvent = "zoom-toggle" }),
	},
	{ key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
	{ key = "n", mods = "CMD", action = act.SpawnWindow },
	{
		key = "t",
		mods = "CMD",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{ key = "d", mods = "CMD", action = wezterm.action({ EmitEvent = "split-right" }) },
	{ key = "d", mods = "CMD|SHIFT", action = wezterm.action({ EmitEvent = "split-down" }) },
	{
		key = ",",
		mods = "CMD",
		action = wezterm.action({ EmitEvent = "move-prev" }),
	},
	{
		key = ".",
		mods = "CMD",
		action = wezterm.action({ EmitEvent = "move-prev" }),
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
	{ key = ",", mods = "CMD|ALT|CTRL", action = act.MoveTabRelative(-1) },
	{ key = ".", mods = "CMD|ALT|CTRL", action = act.MoveTabRelative(1) },
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "=", mods = "CMD", action = act.IncreaseFontSize },
	{ key = ",", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = ".", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = " ", mods = "CTRL|SHIFT", action = act.QuickSelect },
	{ key = "m", mods = "CMD", action = wezterm.action.ToggleFullScreen },
	{ key = " ", mods = "CMD|CTRL", action = act.CharSelect },
	{ key = "H", mods = "CTRL|SHIFT", action = act({ SendString = "\x1b[72;6u" }) },
	{ key = "L", mods = "CTRL|SHIFT", action = act({ SendString = "\x1b[76;6u" }) },

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
