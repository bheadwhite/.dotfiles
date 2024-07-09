local status_ok, lualine = pcall(require, "lualine")
local colors = require("bdub.everforest_colors")
if not status_ok then
	return
end

local hide_in_width = function()
	return vim.fn.winwidth(0) > 80
end

local full_path_minus_filename = function()
	return vim.fn.expand("%:.:h") .. "/"
end

local full_path = function()
	return vim.fn.expand("%:.")
end

local function get_branch()
	require("lualine.components.branch.git_branch").init()
	local branch = require("lualine.components.branch.git_branch").get_branch()
	return string.sub(branch, 1, 40)
end

lualine.setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = "",
		disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
		globalstatus = true,
	},
	sections = {
		lualine_a = {
			get_branch,
		},
		lualine_b = {
			{
				"mode",
				fmt = function(mode)
					return "-- " .. mode .. " --"
				end,
			},
		},
		lualine_c = {
			{
				"diff",
				colored = true,
				symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
				cond = hide_in_width,
			},
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				sections = { "error", "warn" },
				symbols = { error = " ", warn = " " },
				colored = false,
				update_in_insert = false,
				always_visible = true,
			},
		},
		lualine_z = {
			function()
				local current_line = vim.fn.line(".")
				local total_lines = vim.fn.line("$")
				local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
				local line_ratio = current_line / total_lines
				local index = math.ceil(line_ratio * #chars)
				return chars[index]
			end,
		},
	},

	tabline = {
		lualine_a = {},
		lualine_b = {
			{
				full_path_minus_filename,
				padding = 3,
				color = function(section)
					local bg = colors.bg1
					local fg = colors.gray2
					if vim.bo.modified then
						bg = colors.red
						fg = "#ffffff"
					end

					return {
						fg = fg,
						bg = bg,
					}
				end,
			},
		},
		lualine_y = {},
		lualine_z = {
			"tabs",
		},
	},
	extensions = {},
})
