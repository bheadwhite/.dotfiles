local options = {
	backup = false, -- creates a backup file
	cmdheight = 2, -- more space in the neovim command line for displaying messages
	completeopt = { "menuone", "noselect" }, -- mostly just for cmp
	conceallevel = 0, -- so that `` is visible in markdown files
	fileencoding = "utf-8", -- the encoding written to a file
	hlsearch = true, -- highlight all matches on previous search pattern
	incsearch = true, -- show partial matches
	ignorecase = true, -- ignore case in search patterns
	title = true, -- set the title of window to the value of the titlestring
	mouse = "a", -- allow the mouse to be used in neovim
	pumheight = 10, -- pop up menu height
	splitbelow = true, -- force all horizontal splits to go below current window
	showmode = false, -- we don't need to see things like -- INSERT -- anymore
	showtabline = 2, -- always show tabline
	smartcase = true, -- smart case
	splitright = true, -- force all vertical splits to go to the right of current window
	swapfile = false, -- creates a swapfile
	timeoutlen = 500, -- time to wait for a mapped sequence to complete (in milliseconds)
	smartindent = true, -- make indenting smarter again
	undofile = true, -- enable persistent undo
	termguicolors = true, -- set term gui colors (most terminals support this)
	undodir = os.getenv("HOME") .. "/.vim/undodir", -- set an undo directory
	updatetime = 100, -- faster completion (4000ms default)
	writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
	expandtab = true, -- convert tabs to spaces
	shiftwidth = 2, -- the number of spaces inserted for each indentation
	tabstop = 2, -- insert 2 spaces for a tab
	softtabstop = 2, -- insert 2 spaces for a tab
	cursorline = true, -- highlight the current line
	number = true, -- set numbered lines
	relativenumber = false, -- set relative numbered lines
	numberwidth = 4, -- set number column width to 2 {default 4}
	hidden = true,
	signcolumn = "auto", -- always show the sign column, otherwise it would shift the text each time
	wrap = false, -- display lines as one long line
	linebreak = true, -- companion to wrap, don't split words
	scrolloff = 8, -- minimal number of screen lines to keep above and below the cursor
	sidescrolloff = 8, -- minimal number of screen columns either side of cursor if wrap is `false`
	guifont = "monospace:h17", -- the font used in graphical neovim applications
}

vim.opt.shortmess:append("c")
vim.opt.isfname:append("@-@")

for k, v in pairs(options) do
	vim.opt[k] = v
end

-- disable netrw at the very start of your init.lua (strongly advised) per :h nvim-tree-quickstart
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd("set whichwrap+=<,>,[,],h,l")
vim.cmd([[set iskeyword+=-]])
vim.cmd([[set runtimepath+=~/.vim/bundle/bbye]])
