local diagnostics = require("bdub.diagnostics")

local function add_desc(desc, table)
  local opts = {}
  opts.desc = desc
  opts = vim.tbl_extend("force", opts, table or {})
  return opts
end

local options = {
  noremap = true,
  silent = true,
}

function ToggleGit()
  if vim.bo.filetype == "fugitive" then
    vim.cmd.q()
  else
    vim.cmd([[Git]])
  end
end

function vSplit()
  -- vertically split the window and jump back to the original window
  vim.cmd([[vsplit | wincmd p]])
end

local function goToConstructor()
  local after_search_pattern = [[\v(export|constructor\(|__init__)]]
  local constructor = [[\v(constructor\(|__init__)]]

  local found = vim.fn.search(constructor, "nw")

  if found ~= 0 then
    vim.fn.setreg("/", constructor)
    vim.cmd("normal! /" .. constructor)

    vim.cmd("normal! n")
    vim.cmd("normal! zz")
  end
  vim.fn.setreg("/", after_search_pattern)
  vim.cmd("nohlsearch")
end

-- Function to check if the previous character is a whitespace
local function is_previous_char_whitespace()
  -- Get the current cursor position
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  -- If the cursor is at the start of a line, there's no previous character
  if col == 0 then
    return false
  end
  -- Get the previous character
  local line = vim.api.nvim_get_current_line()
  local prev_char = line:sub(col, col)
  -- Check if the previous character is a whitespace
  return prev_char:match("%s") ~= nil
end

local function handleClose()
  -- Get a list of all windows
  local windows = vim.api.nvim_list_wins()

  -- Count only the listed and loaded buffers in all windows
  local listed_buffers = 0
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      listed_buffers = listed_buffers + 1
    end
  end

  -- If only one buffer is listed and loaded, use :bd, else use :q
  if listed_buffers == 1 then
    vim.cmd("bd")
  else
    vim.cmd("q")
  end
end

local highlight_under_cursor = function()
  local current_word = vim.fn.expand("<cword>")
  local found = vim.fn.search(current_word, "nw")

  if found == 0 then
    error("word not found")
  else
    -- highlight the word and set as search register
    vim.fn.setreg("/", current_word)
    vim.cmd("set hlsearch")
    require("hlslens").start()

    -- if previous character is alphanumeric, hit the "b" key to go back one word
    local isPreviousCharWhitespace = is_previous_char_whitespace()
    if not isPreviousCharWhitespace then
      vim.cmd("normal! b")
    end
  end
end

local active_tab = 1

vim.api.nvim_create_autocmd("TabEnter", {
  pattern = "*",
  callback = function()
    active_tab = vim.api.nvim_get_current_tabpage()
  end,
})
vim.api.nvim_create_autocmd("FocusGained", {
  pattern = "*",
  callback = function()
    local current = vim.api.nvim_get_current_tabpage()
    if current ~= active_tab then
      vim.cmd("tabnext " .. active_tab)
    end
  end,
})

local normal_keymaps = {
  { "gj", "mzJ`z", "join" },
  { "<c-d>", "<c-d>zz", "half page down" },
  { "<C-u>", "<C-u>zz", "half page up" },
  { "n", "nzzzv", "next with cursor centered" },
  { "N", "Nzzzv", "prev with cursor centered" },
  { "S", "vg_", "select until EOL" },
  { "Q", "<nop>", "disable ex mode" },
  { "<C-M-g>", ToggleGit, "git" },
  { "<leader>>", "<cmd>lnext<CR>zz", "next location" },
  { "<leader><", "<cmd>lprev<CR>zz", "prev location" },
  {
    "<leader>Ofj",
    function()
      require("bdub.commands").format_jq()
    end,
    "format json",
  },
  -- { "<C-S-h>", "<cmd>bprev<CR>", "prev buffer" },
  -- { "<C-S-l>", "<cmd>bnext<CR>", "next buffer" },
  { "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "substitue under cursor" },
  { "<leader>X", "<cmd>!chmod +x %<CR>", "make file executable" },
  { "<leader>w", ":w<CR>", "write" },
  { "<C-\\>", vSplit, "vertical split" },
  { "<C-M-S-j>", "<cmd>cnext<CR>zz", "next quickfix" },
  { "<C-M-S-k>", "<cmd>cprev<CR>zz", "prev quickfix" },
  { "<C-M-S-q>", "<cmd>cclose<CR>", "close quickfix" },
  { "<leader>q", handleClose, "close buffer" },
  {
    "<C-M-r>",
    function()
      require("bdub.commands").copy_file_path()
    end,
    "copy file path",
  },
  { "<C-Up>", ":resize -2<CR>", "resize split -2" },
  { "<C-Down>", ":resize +2<CR>", "resize split +2" },
  { "<C-Left>", ":vertical resize -2<CR>", "resize vertical split -2" },
  { "<C-Right>", ":vertical resize +2<CR>", "resize vertical split +2" },
  { "<leader>GPT", "<cmd>CopilotChat<CR>", "new gpt split" },
  { "<C-,>", vim.cmd.tabp, "prev tab" },
  { "<C-.>", vim.cmd.tabn, "next tab" },
  { "*", highlight_under_cursor, "for jumps" },
  { "gn", goToConstructor, "go to constructor" },
}

for _, value in ipairs(normal_keymaps) do
  vim.keymap.set("n", value[1], value[2], add_desc(value[3], options))
end

--
local function set_custom_highlight()
  local background_color = "#1E2326" -- Replace with your desired color
  vim.cmd(string.format("highlight CustomFloating guibg=%s", background_color))
end

set_custom_highlight()

vim.api.nvim_set_keymap("v", "p", '"_dP', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rr", require("bdub.win_utils").printCurrentWindow, add_desc("print windows"))
local tiny_dkagnostics_enabled = true
vim.keymap.set("n", "gd", function()
  if tiny_diagnostics_enabled then
    -- vim.notify("Inline diagnostics disabled", "error", {
    --   title = "Tiny Inline Diagnostic",
    -- })
    tiny_diagnostics_enabled = false
  else
    vim.notiky("Inline diagnostics enabled", "info", {
      title = "Tiny Inline Diagnostic",
    })
    tiny_diagnostics_enabled = true
  end

  vim.diagnostic.config(diagnostics.GetDiagnosticConfig(tiny_diagnostics_enabled and "on" or "off"))

  require("tiny-inline-diagnostic").toggle()
end, add_desc("toggle inline diagnostics"))

function split_line_by()
  local split_by_value = vim.fn.input("Split line by: (default is:, ) ", ", ")
  local expression = string.format([[s/\v(%s)/\1\r/g]], split_by_value)
  vim.cmd(expression)
end

function wezterm_cmd(cmd)
  -- local curWin = vim.api.nvim_get_current_win()
  local curTab = vim.api.nvim_get_current_tabpage()
  vim.cmd("silent ! " .. cmd .. " > /dev/null 2>&1")
  vim.defer_fn(function()
    vim.api.nvim_set_current_tabpage(curTab)
  end, 0)
end

vim.keymap.set({ "n", "v" }, "<C-F13>", function()
  wezterm_cmd("wezterm cli zoom-pane --toggle")
end, add_desc("zoom wezterm"))

vim.keymap.set({ "n", "v" }, "<C-F14>", function()
  wezterm_cmd("wezterm cli split-pane --right")
end, add_desc("new split"))

vim.keymap.set({ "n", "v" }, "<C-F15>", function()
  wezterm_cmd("wezterm cli split-pane --bottom")
end, add_desc("new split"))

-- You can then call this function with `:lua open_buffer_in_floating_window()`

-- vim.keymap.set("n", "<leader>os", split_line_by, add_desc("split line by"))

-- system clipboard
vim.keymap.set("x", "<leader>P", [["_dP]], add_desc("Paste over selection"))
vim.keymap.set("x", "c", '"_c', options)
vim.keymap.set({ "n", "v" }, "<C-M-c>", [["+y]], add_desc("Copy to system clipboard"))

vim.keymap.set("c", "<M-k>", "\\(.*\\)", {
  desc = "one eyed fighting kirby",
})

vim.keymap.set("v", "/", "<Esc>/\\%V", add_desc("search visual selection"))
vim.keymap.set({ "n", "v" }, "j", "gj", options)
vim.keymap.set({ "n", "v" }, "k", "gk", options)
vim.keymap.set({ "n", "v" }, "J", function() end, options)
vim.keymap.set({ "n", "v" }, "L", "$", options)
vim.keymap.set({ "n", "v" }, "H", "_", options)
vim.keymap.set({ "n", "v", "x" }, "<C-k>", "<C-w>k", add_desc("move to top window"))
vim.keymap.set({ "n", "v", "x" }, "<C-l>", "<C-w>l", add_desc("move to right window"))
vim.keymap.set({ "n", "v", "x" }, "<C-j>", "<C-w>j", add_desc("move to bottom window"))
vim.keymap.set({ "n", "v", "x" }, "<C-h>", "<C-w>h", add_desc("move to left window"))
vim.keymap.set({ "n", "v" }, "<C-t>", vim.cmd.tabe, add_desc("new tab"))
vim.keymap.set("n", "<leader>c", ":Bdelete<cr>", { noremap = true, desc = "close buffer" })
vim.keymap.set("n", "<leader>C", ":Bdelete!<cr>", { noremap = true, desc = "close buffer" })

vim.keymap.set("n", "<esc>", "<cmd>noh<cr><esc>", add_desc("esc normal"))

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", options)
