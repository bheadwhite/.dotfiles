local isOk, neoTree = pcall(require, "neo-tree")
if not isOk then
	return
end

local commands = require("bdub.commands")

vim.cmd([[let g:neo_tree_remove_legacy_commands = 1]])

neoTree.setup({
	source_selector = {
		winbar = true,
	},
	event_handlers = {
		{
			event = "file_opened",
			handler = function(fileName)
				print(fileName)
				vim.cmd([[Neotree close]])
			end,
		},
	},
	filesystem = {
		bind_to_cwd = false,
		find_by_full_path_words = true,
		filtered_items = {
			hide_by_pattern = {
				--"*.meta",
				--"*/src/*/tsconfig.json",
			},
		},
		window = {
			mappings = {
				["<space>"] = "noop",
				[","] = "open_drop",
				["F"] = function(state)
					local node = state.tree:get_node()
					require("telescope.builtin").live_grep({
						prompt_title = "grep files in " .. node.name,
						search_dirs = { node.path },
					})
				end,
				["<C-M-r>"] = function(state)
					local node = state.tree:get_node()
					commands.copy_operator_file_path(node.path)
				end,
			},
		},
	},
})

local toggleTree = function()
	vim.cmd([[Neotree toggle reveal]])
end

vim.keymap.set("n", "<leader>e", toggleTree, { noremap = true, silent = true, desc = "toggle file tree" })
