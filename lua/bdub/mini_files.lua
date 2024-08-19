return {
	setup = function()
		local mini_files = require("mini.files")
		local PlenaryPath = require("plenary.path")

		local commands = {
			{
				"n",
				"<CR>",
				function()
					mini_files.go_in()
					mini_files.close()
				end,
			},
			{
				"n",
				"<leader>w",
				mini_files.synchronize,
			},
			{
				"n",
				"<ESC>",
				function()
					mini_files.close()
				end,
			},
			{
				"n",
				"<C-v>",
				function()
					local entry = mini_files.get_fs_entry()
					if entry.path then
						vim.cmd("vsplit" .. entry.path)
						mini_files.open()
					end
				end,
			},
			{
				"n",
				"<C-M-r>",
				function()
					local entry = mini_files.get_fs_entry()
					local rPath = PlenaryPath:new(entry.path):make_relative()
					vim.fn.setreg("+", rPath)
					print("copied path: " .. rPath)
				end,
			},
			{
				"n",
				"F",
				function()
					local entry = mini_files.get_fs_entry()
					local dir = entry.path
					mini_files.close()

					require("telescope").extensions.live_grep_args.live_grep_args({
						prompt_title = "ripgrep search in " .. dir,
						search_dirs = { dir },
					})
				end,
			},
			{
				"n",
				"f",
				function()
					local entry = mini_files.get_fs_entry()
					local dir = entry.path
					mini_files.close()

					require("telescope.builtin").find_files({
						prompt_title = "file search within " .. dir,
						search_dirs = { dir },
					})
				end,
			},
			{
				"n",
				"l",
				function()
					local entry = mini_files.get_fs_entry()
					if entry.fs_type == "directory" then
						mini_files.go_in()
					end
				end,
			},
		}
		-- nvim event
		local augroup = vim.api.nvim_create_augroup("MyMiniFilesGroup", { clear = true })
		local winId = nil

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesExplorerOpen",
			group = augroup,
			callback = function()
				winId = vim.api.nvim_get_current_win()
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			group = augroup,
			callback = function(args)
				for _, command in ipairs(commands) do
					vim.keymap.set(command[1], command[2], command[3], { noremap = true, silent = true, buffer = args.data.buf_id })
				end
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesExplorerClose",
			group = augroup,
			callback = function()
				winId = nil
			end,
		})

		local get_open_or_cb = function(cb)
			return function()
				if winId then
					cb()
					return
				end

				require("mini.files").open()
			end
		end

		vim.keymap.set("n", "-", get_open_or_cb(mini_files.go_out), {
			noremap = true,
			desc = "open mini files",
		})

		vim.keymap.set("n", "<leader>e", get_open_or_cb(mini_files.close), {
			noremap = true,
			desc = "close mini files",
		})
	end,
}
