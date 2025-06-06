local wezterm = require("wezterm")
local keys = require("config.keys")
local cfg = require("config.init")
local tab_title = require("config.tab_title")
local events = require("config.events")

local config = {}

if wezterm.config_builder then
	-- help provide clearer error messages
	config = wezterm.config_builder()
end

for k, v in pairs(cfg) do
	config[k] = v
end

config.keys = keys

--custom events
wezterm.on("move-next", events.moveNextPane)
wezterm.on("move-prev", events.movePrevPane)
wezterm.on("split-right", events.splitRight)
wezterm.on("zoom-toggle", events.zoomToggle)
wezterm.on("split-down", events.splitDown)
wezterm.on("toggle_background", events.toggle_background)

wezterm.on("update-right-status", events.setRightStatus)

--wezterm events
wezterm.on("format-tab-title", tab_title.formatTabTitle)
wezterm.on("window-config-reloaded", events.apply_color_scheme)
wezterm.on("window-focus-changed", events.apply_color_scheme)

return config
