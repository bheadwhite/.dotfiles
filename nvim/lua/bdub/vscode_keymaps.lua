local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- remap leader key
keymap("n", "<Space>", "", opts)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("n", "<Esc>", "<Esc>:noh<CR>", opts)

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


function cursorToParent()
  --find constructor if none found then notify such and return
  local found = vim.fn.search("constructor(")

  if found == 0 then
    local defaultFound = vim.fn.search("export default")

    if defaultFound == 0 then
      local exportFound = vim.fn.search("export", "bW")

      if exportFound == 0 then
        notify.notify("No constructor, or export found", "error", { title = "Jump to Parent", timeout = 200 })
        return false
      end
    end

    vim.cmd("normal! ww")
  end

  return true
end

keymap({"n", "v"}, "<leader>f", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
keymap({"n", "v"}, "<leader>p", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
keymap({"n", "v"}, "<leader>q", "<cmd>lua require('vscode').action('workbench.action.closeActiveEditor')<CR>")
keymap({"n", "v"}, "<leader>z", "<cmd>lua require('vscode').action('workbench.action.toggleMaximizeEditorGroup')<CR>")
keymap({"n", "v"}, "<leader>gr", "<cmd>lua require('vscode').action('git.revertSelectedRanges')<CR>")
keymap({"n", "v"}, "<leader>gR", "<cmd>lua require('vscode').action('git.clean')<CR>")
keymap({"n", "v"}, "<leader>gp", "<cmd>lua require('vscode').action('editor.action.dirtydiff.next')<CR>")
keymap({"n", "v"}, "<leader>gd", "<cmd>lua require('vscode').action('workbench.scm.focus')<CR>")
keymap({"n", "v"}, "<leader>r", "<cmd>lua require('vscode').action('editor.action.renameFile')<CR>")
keymap({"n", "v"}, "<leader>lr", "<cmd>lua require('vscode').action('references-view.tree.focus')<CR>")
keymap({"n", "v"}, "<leader>s", "<cmd>lua require('vscode').action('workbench.action.findInFiles')<CR>")
keymap({"n", "v"}, "<leader>o", "<cmd>lua require('vscode').action('workbench.action.closeOtherEditors')<CR>")
keymap({"n", "v"}, "<leader>O", "<cmd>lua require('vscode').action('workbench.action.closeEditorsInOtherGroups')<CR>")
keymap({"n", "v"}, "<leader>.", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")

keymap({"n", "v"}, "gi", "<cmd>lua require('vscode').action('editor.action.referenceSearch.trigger')<CR>")
keymap({"n", "v"}, "gr", "<cmd>lua require('vscode').action('editor.action.goToReferences')<CR>")
keymap({"n", "v"}, "gR", "<cmd>lua require('vscode').action('references-view.findReferences')<CR>")
keymap({"n", "v"}, "gI", function()
  local action = require('vscode').action
  action("workbench.action.splitEditor")
  action("editor.action.revealDefinition")
  vim.wait(1000)
  action("workbench.action.closeOtherEditors")
end)

keymap({"n", "v"}, "gD", function()
  local action = require('vscode').action
  action("workbench.action.splitEditor")
  action("editor.action.goToImplementation")
  vim.wait(1000)
  action("workbench.action.closeOtherEditors")
end)

keymap({"n", "v"}, "gp", function()
  if not cursorToParent() then
    return
  end

  local vscode = require('vscode')
  local symbol = vim.fn.expand('<cword>')

  -- Use VSCode's reference search with a callback to get count
  vscode.action('editor.action.goToReferences' )
end)
keymap({"n", "v"}, "gn", function()
  if not cursorToParent() then
    return
  end

  local vscode = require('vscode')
  local symbol = vim.fn.expand('<cword>')

  -- Use VSCode's reference search with a callback to get count
  vscode.action('editor.action.goToReferences' )
end)
keymap({"n", "v"}, "gt", "<cmd>lua require('vscode').action('editor.action.goToTypeDefinition')<CR>")
keymap({"n", "v"}, "gT", function()
  local action = require('vscode').action
  action("workbench.action.splitEditor")
  action("editor.action.goToTypeDefinition")
  vim.wait(1000)
  action("workbench.action.closeOtherEditors")
end)

