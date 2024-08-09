return {
	"stevearc/oil.nvim",
	config = function()
		local oil = require("oil")
		local oil_helpers = require("bdub._oil")
		oil.setup({
			view_options = {
				show_hidden = true,
			},
			keymaps = {
				["<C-h>"] = false,
				["<C-l>"] = false,
				["<C-j>"] = false,
				["<C-k>"] = false,
				["<C-v>"] = oil_helpers.openFileAndSwap,
				["<C-S-S>"] = function()
					require("oil.actions").select_split()
				end,
				["<C-M-r>"] = function()
					local relative = oil_helpers.getCursorRelativePath()
					local custom_commands = require("bdub.commands")

					custom_commands.copy_operator_file_path(relative)
				end,
				["F"] = function()
					local entry = oil.get_cursor_entry()
					local dir = oil.get_current_dir()

					if entry.type == "directory" then
						dir = dir .. entry.name
					end

					require("telescope").extensions.live_grep_args.live_grep_args({
						prompt_title = "ripgrep search in " .. dir,
						search_dirs = { dir },
					})
				end,
				["f"] = function()
					local entry = oil.get_cursor_entry()
					local dir = oil.get_current_dir()

					if entry.type == "directory" then
						dir = dir .. entry.name
					end

					require("telescope.builtin").find_files({
						prompt_title = "file search within " .. dir,
						search_dirs = { dir },
					})
				end,
			},
		})
	end,
}
