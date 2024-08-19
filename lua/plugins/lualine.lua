return {
	"nvim-lualine/lualine.nvim", -- statusline
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local colors = require("bdub.everforest_colors")
		local lualine = require("lualine")

		local hide_in_width = function()
			return vim.fn.winwidth(0) > 80
		end

		local full_path_minus_filename = function()
			return vim.fn.expand("%:.:h") .. "/"
		end

		local function get_branch()
			require("lualine.components.branch.git_branch").init()
			local branch = require("lualine.components.branch.git_branch").get_branch()
			return string.sub(branch, 1, 40)
		end

		local anchor_icon = vim.fn.nr2char(0xf13d)

		lualine.setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = "",
				disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
				globalstatus = true,
			},
			tabline = {
				lualine_a = {},
				lualine_b = {
					{
						full_path_minus_filename,
						color = function() -- arg:  section
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
				lualine_x = {
					--current working directory
				},
				lualine_y = {},
				lualine_z = {
					"tabs",
				},
			},
			sections = {
				lualine_a = {
					{
						function()
							return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
						end,
						padding = 1,
						color = { fg = "#ffffff", bg = colors.aqua },
					},
					function()
						return require("auto-session.lib").current_session_name(true)
					end,
					{

						function()
							local grapple = require("grapple")
							local app = grapple.app()
							if app == nil then
								return ""
							end
							local scope = app.scope_manager:get(app.settings.scope)
							return anchor_icon .. " " .. scope.name
						end,
						color = { fg = "#ffffff", bg = colors.bg1 },
					},
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
				lualine_c = {},
				lualine_z = {
					function()
						local current_line = vim.fn.line(".")
						local total_lines = vim.fn.line("$")
						local chars =
							{ "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
						local line_ratio = current_line / total_lines
						local index = math.ceil(line_ratio * #chars)
						return chars[index]
					end,
				},
			},
			extensions = {},
		})
	end,
}
