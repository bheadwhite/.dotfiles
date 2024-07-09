require("nvim-treesitter.configs").setup({
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["ib"] = "@block.inner",
				["ab"] = "@block.outer",
				["ia"] = "@parameter.inner",
				["aa"] = "@parameter.outer",
			},
		},
	},
	textsubjects = {
		enable = true,
		prev_selection = "<S-CR>", -- (Optional) keymap to select the previous selection
		keymaps = {
			["<cr>"] = "textsubjects-smart",
			["."] = "textsubjects-container-outer",
			[","] = "textsubjects-container-inner",
		},
	},
	-- A list of parser names, or "all"
	ensure_installed = { "javascript", "typescript", "c", "lua", "rust" },
	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,
	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,
	highlight = {
		-- `false` will disable the whole extension
		enable = true,
		disable = { "css" },

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
	autotag = {
		enable = true,
	},
	indent = { enable = true, disable = { "python", "css" } },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-M-o>", -- maps in normal mode to init the node/scope selection
			node_incremental = "<C-M-o>", -- increment to the upper named parent
			node_decremental = "<C-M-i>", -- decrement to the previous node
		},
	},
})

-- background color of the current buffer

-- Function to set the background color of the current buffer
local function set_current_buffer_highlight()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_option(bufnr, "winhighlight", "Normal:NormalSB")
end

-- Function to clear the background color of non-current buffers
local function clear_buffer_highlight()
	local buffers = vim.api.nvim_list_bufs()
	for _, bufnr in ipairs(buffers) do
		vim.api.nvim_buf_set_option(bufnr, "winhighlight", "")
	end
end

-- Function to update buffer highlights
local function update_buffer_highlights()
	clear_buffer_highlight()
	set_current_buffer_highlight()
end

-- Autocommand to update buffer highlights when changing buffer
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	callback = function()
		update_buffer_highlights()
	end,
})

-- Set initial highlight
update_buffer_highlights()
