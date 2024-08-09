return {
	"stevearc/aerial.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("aerial").setup({
			close_on_select = true,
			post_parse_symbol = function(bufnr, item, ctx)
				local line = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]
				if line == nil then
					return true
				end

				local keywords = { " protected", " private ", " action ", " constructor" }
				for _, keyword in ipairs(keywords) do
					if string.match(line, keyword) then
						return false
					end
				end

				return true
			end,
		})
		local toggle_aerial = function()
			require("aerial").toggle()
		end

		vim.keymap.set("n", "<C-M-a>", toggle_aerial, { silent = true, desc = "aerial toggle" })
	end,
}
