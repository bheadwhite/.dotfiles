local status_ok, lualine = pcall(require, "lualine")
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

local function maximize_status()
	return vim.t.maximized and "   " or ""
end

lualine.setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
		always_divide_middle = true,
	},
	sections = {
		lualine_a = {
			get_branch,
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
		lualine_b = {
			{
				"mode",
				fmt = function(mode)
					return "-- " .. mode .. " --"
				end,
			},
		},
		-- lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_x = {
			{
				"diff",
				colored = false,
				symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
				cond = hide_in_width,
			},
			"encoding",
			{
				"filetype",
				icons_enabled = false,
				icon = nil,
			},
		},
		lualine_y = { "location" },
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
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { { "filename", fmt = full_path } },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {
		lualine_a = {
			{
				"filename",
				fmt = full_path_minus_filename,
				path = 1,
				color = { fg = "#fffff", bg = "" },
			},
			{
				"filename",
				modified = true,
				show_modified_status = true,
				symbols = {
					modified = " ●", -- Text to show when the buffer is modified
					color = {},
					alternate_file = "#", -- Text to show to identify the alternate file
					directory = "", -- Text to show when the buffer is a directory
				},
			},
			{
				maximize_status,
				color = { fg = "#fffff", bg = "" },
			},
		},
		lualine_z = {
			{
				"tabs",
			},
		},
	},
	extensions = {},
})
