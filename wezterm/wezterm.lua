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

-- Assigning a key_table REPLACES wezterm's built-in one for that mode rather
-- than merging, so start from the defaults and append. Re-fetch per table:
-- default_key_tables() hands back a fresh copy each call, but the tables inside
-- one call are shared, so mutating in place would leak edits between them.
local function extend_default_key_table(name, extra)
	local t = wezterm.gui.default_key_tables()[name]
	for _, binding in ipairs(extra) do
		table.insert(t, binding)
	end
	return t
end

-- macOS find-again: Cmd+G steps to the next match, Cmd+Shift+G to the previous,
-- completing the Cmd+F (act.Search) flow in config/keys.lua. Bound in both modes
-- because Cmd+F lands in search_mode and Enter promotes that to copy_mode --
-- match cycling should keep working across the handoff.
-- `phys:G` (not "g"/"G") so the SHIFT variant matches: with shift held, macOS
-- reports the key as "G" and wezterm's mods/key normalization gets ambiguous.
-- Same reason as the phys:Comma / phys:Period bindings in config/keys.lua.
local find_again = {
	{ key = "phys:G", mods = "CMD", action = wezterm.action.CopyMode("NextMatch") },
	{ key = "phys:G", mods = "CMD|SHIFT", action = wezterm.action.CopyMode("PriorMatch") },
}

-- confirm-mode for closing a pane: cmd+w arms this table, a second cmd+w (or y)
-- confirms the close, Escape or any unknown key cancels.
config.key_tables = {
	confirm_close = {
		{ key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
		{ key = "y", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
		{ key = "Escape", action = "PopKeyTable" },
	},
	search_mode = extend_default_key_table("search_mode", find_again),
	copy_mode = extend_default_key_table("copy_mode", find_again),
}

--custom events
wezterm.on("move-next", events.moveNextPane)
wezterm.on("move-prev", events.movePrevPane)
wezterm.on("split-right", events.splitRight)
wezterm.on("zoom-toggle", events.zoomToggle)
wezterm.on("split-down", events.splitDown)
wezterm.on("smart-paste", events.smartPaste)
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
