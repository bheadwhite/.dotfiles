return {
	setup = function()
		local mini_files = require("mini.files")
		local PlenaryPath = require("plenary.path")
		local activeWinId = nil

		local commands = {
			{
				"n",
				"<CR>",
				function()
					local entry = mini_files.get_fs_entry()
					if entry.fs_type == "directory" then
						mini_files.go_in()
						return
					end

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
				"-",
				function()
					mini_files.go_out()
				end,
			},
		}
		-- nvim event
		local augroup = vim.api.nvim_create_augroup("MyMiniFilesGroup", { clear = true })

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesExplorerOpen",
			group = augroup,
			callback = function()
				activeWinId = vim.api.nvim_get_current_win()
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
				activeWinId = nil
			end,
		})

		local get_open_or_cb = function(cb)
			return function()
				local win = vim.api.nvim_get_current_win()
				local buf = vim.api.nvim_win_get_buf(win)
				local buf_name = vim.api.nvim_buf_get_name(buf)
				if buf_name:match("oil") then
					require("oil").close()
					return
				end

				if activeWinId then
					return cb()
				end

				-- current buffer directory
				local bufname = vim.fn.expand("%:p")
				-- if the current buffer is a file, then open the current directory

				require("mini.files").open(bufname)
			end
		end

		vim.keymap.set("n", "<leader>e", get_open_or_cb(mini_files.close), {
			noremap = true,
			desc = "close mini files",
		})
	end,
}
