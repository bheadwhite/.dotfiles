local wezterm = require("wezterm")
local act = wezterm.action

return {
	{
		-- First cmd+w arms confirm-mode (see key_tables.confirm_close in wezterm.lua).
		-- A second cmd+w or y within the timeout closes the pane; any other key cancels.
		key = "w",
		mods = "CMD",
		action = act.ActivateKeyTable({
			name = "confirm_close",
			one_shot = true,
			timeout_milliseconds = 1500,
			until_unknown = true,
		}),
	},
	{
		key = "z",
		mods = "CMD",
		action = wezterm.action({ EmitEvent = "zoom-toggle" }),
	},
	{ key = "c", mods = "CMD|SHIFT", action = act.ActivateCopyMode },
	{ key = "v", mods = "CMD", action = wezterm.action({ EmitEvent = "smart-paste" }) },
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
		action = act.ActivatePaneDirection("Prev"),
	},
	{
		key = ".",
		mods = "CMD",
		action = act.ActivatePaneDirection("Next"),
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
	{
		key = "UpArrow",
		mods = "SHIFT",
		action = act.ScrollByPage(-1),
	},
	{
		key = "DownArrow",
		mods = "SHIFT",
		action = act.ScrollByPage(1),
	},
	{ key = ",", mods = "ALT", action = act.MoveTabRelative(-1) },
	{ key = ".", mods = "ALT", action = act.MoveTabRelative(1) },
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "=", mods = "CMD", action = act.IncreaseFontSize },
	{ key = ",", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = ".", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "phys:Comma", mods = "CTRL|SHIFT", action = act.SendString("\x1b[44;6u") },
	{ key = "phys:Period", mods = "CTRL|SHIFT", action = act.SendString("\x1b[46;6u") },
	{ key = " ", mods = "CTRL|SHIFT", action = act.QuickSelect },
	{ key = "m", mods = "CMD", action = wezterm.action.ToggleFullScreen },
	{ key = " ", mods = "CMD|CTRL", action = act.CharSelect },
	-- { key = "H", mods = "CTRL|SHIFT", action = act({ SendString = "\x1b[72;6u" }) },
	-- { key = "L", mods = "CTRL|SHIFT", action = act({ SendString = "\x1b[76;6u" }) },

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

	-- Accept the AI/history suggestion — Hyper+Enter (Caps Lock + Enter).
	-- Karabiner maps held Caps Lock to right_control+right_alt, so the chord
	-- arrives here as CTRL|ALT (see karabiner.json).
	-- CSI 26;7~ is Ctrl+Alt+F14: zsh binds it to autosuggest-accept (see
	-- config/zsh/keybindings.zsh) and nvim reads it as <C-M-F14> to accept a
	-- Copilot/sidekick suggestion. Ghostty sends the same bytes from its own
	-- config, so one chord means one thing in every terminal.
	-- This used to be a BetterTouchTool rewrite scoped to the WezTerm bundle id,
	-- which is exactly why it never worked in ghostty/cmux — send it natively so
	-- the binding lives with the terminal config instead of drifting in BTT.
	{ key = "Enter", mods = "CTRL|ALT", action = act.SendString("\x1b[26;7~") },

	{
		key = "F12",
		action = wezterm.action.EmitEvent("toggle_background"),
	},
}
