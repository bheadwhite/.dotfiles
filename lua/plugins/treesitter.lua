return {
	"nvim-treesitter/nvim-treesitter",
	config = function()
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
			indent = {
				enable = true,
				disable = { "python", "css" },
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-M-o>", -- maps in normal mode to init the node/scope selection
					node_incremental = "<C-M-o>", -- increment to the upper named parent
					node_decremental = "<C-M-i>", -- decrement to the previous node
				},
			},
		})
	end,
}
