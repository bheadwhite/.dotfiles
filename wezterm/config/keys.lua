local wezterm = require("wezterm")
local act = wezterm.action

return {
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
}
