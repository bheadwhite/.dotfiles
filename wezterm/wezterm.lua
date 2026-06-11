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

-- confirm-mode for closing a pane: cmd+w arms this table, a second cmd+w (or y)
-- confirms the close, Escape or any unknown key cancels.
config.key_tables = {
	confirm_close = {
		{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
		{ key = "y", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
		{ key = "Escape", action = "PopKeyTable" },
	},
}

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

-- task-loop: clicking a "▶ tail T<n>" link in the daemon log (.task-loop.log)
-- splits the pane in half and tails that worker's log. The daemon emits these as
-- OSC 8 hyperlinks with a custom tailworker:// scheme.
wezterm.on("open-uri", function(window, pane, uri)
	local prefix = "tailworker://"
	if uri:sub(1, #prefix) == prefix then
		local path = uri:sub(#prefix + 1)
		window:perform_action(
			wezterm.action.SplitPane({
				direction = "Right",
				size = { Percent = 50 },
				command = { args = { "tail", "-n", "200", "-F", path } },
			}),
			pane
		)
		return false -- handled — don't hand the custom scheme to the OS opener
	end
	-- any other uri: return nothing so WezTerm opens it normally
end)

return config
