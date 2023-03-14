-- vim.g.everforest_transparent_background = 1

function ColorMyPencils(color)
	color = color or "everforest"
	vim.cmd.colorscheme(color)

	vim.cmd([[hi link CurSearch IncSearch]])
end

ColorMyPencils()
