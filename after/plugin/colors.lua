-- vim.g.everforest_transparent_background = 1

function ColorMyPencils(color)
	color = color or "everforest"
	vim.cmd.colorscheme(color)

	-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencils()
