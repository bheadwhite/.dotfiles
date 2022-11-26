-- disable netrw at the very start of your init.lua (strongly advised) per :h nvim-tree-quickstart
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require "bdub.lsp"

-- plugins
require "bdub.plugins"
require "bdub.treesitter"
require "bdub.gitsigns"
require "bdub.nvim-tree"
require "bdub.telescope"
require "bdub.harpoon"
require "bdub.comment"
require "bdub.autocommands"
require "bdub.impatient"
require "bdub.autopairs"
require "bdub.cmp"
require "bdub.lualine"
require "bdub.gomove"
require "bdub.toggleterm"
require "bdub.tabout"
require "bdub.maximizer"
require "bdub.indentline"
require "bdub.whichkey"
require "bdub.copilot"
require "bdub.diffview"

-- vim base
require "bdub.keymaps"
require "bdub.options"
require "bdub.colorscheme"
