local actions = require("diffview.actions")
local lib = require("diffview.lib")

function activate_win_by_buffer_name()
	local path = lib.get_current_view():infer_cur_file().absolute_path
	if not path then
		actions.goto_file_edit()
	end

	local current_tabpage = vim.api.nvim_get_current_tabpage()
	local tabpages = vim.api.nvim_list_tabpages()
	local emptyBufferId = nil
	for _, tabpage in ipairs(tabpages) do
		local windows = vim.api.nvim_tabpage_list_wins(tabpage)

		for _, win in ipairs(windows) do
			local buf = vim.api.nvim_win_get_buf(win)
			local bufname = vim.api.nvim_buf_get_name(buf)
			if bufname == "" and #tabpages > 1 and #windows == 1 then
				emptyBufferId = buf
			end
			local is_current_tab = tabpage == current_tabpage
			if bufname:match(path) and not is_current_tab then
				-- Activate the tab
				vim.api.nvim_set_current_tabpage(tabpage)
				-- Optionally, activate the window with the matching buffer
				vim.api.nvim_set_current_win(win)

				require("gitsigns").next_hunk()
				vim.cmd([[normal! zz]])

				found = true -- Pattern found and tab activated
			end
		end
	end

	if emptyBufferId then
		vim.api.nvim_buf_delete(emptyBufferId, { force = true })
	end

	if not found then
		if #tabpages == 1 then
			actions.goto_file_tab()

			require("gitsigns").next_hunk()
			vim.cmd([[normal! zz]])
		else
			actions.goto_file_edit()
			require("gitsigns").next_hunk()
			vim.cmd([[normal! zz]])
		end
	end
end

function open_diff_view()
	local found = false
	local pattern = "diffview:///panels/0/DiffviewFilePanel"
	local tabpages = vim.api.nvim_list_tabpages()
	local emptyBufferId = nil
	for _, tabpage in ipairs(tabpages) do
		local windows = vim.api.nvim_tabpage_list_wins(tabpage)
		for _, win in ipairs(windows) do
			local buf = vim.api.nvim_win_get_buf(win)
			local bufname = vim.api.nvim_buf_get_name(buf)
			if bufname == "" and #tabpages > 1 and #windows == 1 then
				emptyBufferId = buf
			end
			if bufname:match(pattern) then
				-- Activate the tab
				vim.api.nvim_set_current_tabpage(tabpage)
				-- Optionally, activate the window with the matching buffer
				vim.api.nvim_set_current_win(win)
				found = true -- Pattern found and tab activated
			end
		end
	end

	if not found then
		vim.cmd([[DiffviewOpen]])
	end

	if emptyBufferId then
		vim.api.nvim_buf_delete(emptyBufferId, { force = true })
	end
end

vim.keymap.set("n", "<leader>gd", open_diff_view, { desc = "open diffview", noremap = true, silent = true })
vim.keymap.set("n", "<leader>gg", ":DiffviewClose<CR>", { desc = "close diffview", noremap = true, silent = true })

require("diffview").setup({
	keymaps = {
		view = {
			{ "n", "gf", actions.goto_file_tab, { desc = "Open the file in a new split in the previous tabpage" } },
		},
		file_panel = {
			{
				"n",
				"gf",
				activate_win_by_buffer_name,
				{ desc = "Open the file in a new split in the previous tabpage" },
			},
		},
	},
})
