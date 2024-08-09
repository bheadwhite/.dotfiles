return {
	"cbochs/grapple.nvim", -- Bookmarks / tags
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	opts = function()
		local helpers = require("bdub._grapple")
		return {
			scope = helpers.get_active_scope(),
			name_pos = "start",
			win_opts = {
				width = 0.9,
				height = 0.8,
				relative = "editor",
				title_pos = "center",
				focusable = true,
			},
		}
	end,
}
