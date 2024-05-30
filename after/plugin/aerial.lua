local aerial = require("aerial")

aerial.setup({
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

vim.keymap.set("n", "<C-M-a>", function()
	require("aerial").toggle()
end, { silent = true, desc = "aerial toggle" })
