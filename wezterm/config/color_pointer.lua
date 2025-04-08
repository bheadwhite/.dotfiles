local colors = require("config.colors")
local wezterm = require("wezterm")

local M = {
	split = colors.purple,
	background = wezterm.color.parse(colors.bg0),
}

return M
