-- vim.g.everforest_transparent_background = 1
return {
	"neanias/everforest-nvim",
	lazy = false,
	priority = 1000,
	config = function()
		function ColorMyPencils(color)
			color = color or "everforest"
			vim.cmd.colorscheme(color)

			vim.cmd([[hi link CurSearch IncSearch]])
		end

		ColorMyPencils()
	end,
}
