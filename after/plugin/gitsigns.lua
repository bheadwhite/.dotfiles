local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
	return
end

gitsigns.setup({
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
	linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
	word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
	watch_gitdir = {
		interval = 1000,
		follow_files = true,
	},
	attach_to_untracked = true,
	current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
		delay = 1000,
		ignore_whitespace = false,
	},
	current_line_blame_formatter_opts = {
		relative_time = false,
	},
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil, -- Use default
	max_file_length = 40000,
	preview_config = {
		-- Options passed to nvim_open_win
		border = "single",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
	yadm = {
		enable = false,
	},
})

-- blame = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
-- reset_hunk = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
-- reset_buffer = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
-- stage_hunk = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
-- preview_hunk = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "preview hunk" },
-- undo_stage_hunk = { "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", "Undo Stage Hunk" },
-- diff = { "<cmd>Gitsigns diffthis HEAD<cr>", "Diff" },

local last_func = nil
-- use last command function
local function use_last_func()
	if last_func then
		last_func()
	end
end

function function_decorator(func)
	return function()
		last_func = func
		func()
	end
end

local nextHunk = function_decorator(function()
	require("gitsigns").next_hunk()
	vim.cmd([[normal! zz]])
end)

local prevHunk = function_decorator(function()
	require("gitsigns").prev_hunk()
	vim.cmd([[normal! zz]])
end)

vim.keymap.set("n", "<C-M-Enter>", use_last_func, { noremap = true, silent = true, desc = "use last func" })

-- Key mappings to invoke the commands
vim.keymap.set("n", "<C-M-.>", nextHunk, { noremap = true, silent = true, desc = "next hunk" })
vim.keymap.set("n", "<C-M-,>", prevHunk, { noremap = true, silent = true, desc = "prev hunk" })

vim.keymap.set("n", "<leader>gb", "<cmd>lua require 'gitsigns'.blame_line()<cr>", { desc = "blame line" })
vim.keymap.set("n", "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", { desc = "reset hunk" })
vim.keymap.set("n", "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", { desc = "reset buffer" })
vim.keymap.set("n", "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", { desc = "preview hunk" })
