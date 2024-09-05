local oil = require("oil")
local M = {}

function M.getCursorRelativePath()
  local PlenaryPath = require("plenary.path")

  local entry = oil.get_cursor_entry()
  local path = oil.get_current_dir()
  local full_path = path .. entry.name

  return PlenaryPath:new(full_path):make_relative()
end

function M.openFileAndSwap()
  local winshift_lib = require("winshift.lib")
  local cur_win = vim.api.nvim_get_current_win()
  -- -- do your windo, for example:
  -- vim.cmd("windo if &buftype != 'nofile' | let g:non_float_total += 1 | endif")

  local relativePath = M.getCursorRelativePath()

  vim.cmd("vsp " .. relativePath)

  local shouldSwap = vim.fn.winnr() ~= vim.fn.winnr("$")
  if shouldSwap then
    winshift_lib.start_swap_mode()
  end

  vim.api.nvim_set_current_win(cur_win)
end

local function in_oil_buffer()
  return vim.bo.filetype == "oil"
end

function in_neo_tree_buffer()
  return vim.bo.filetype == "neo-tree"
end

-- local function toggle_oil()
-- 	if in_neo_tree_buffer() then
-- 		vim.cmd([[Neotree toggle]])
-- 		return
-- 	end
--
-- 	if in_oil_buffer() then
-- 		oil.close()
-- 	else
-- 		oil.open()
-- 	end
-- end

local function open_oil()
  -- if vim.api.nvim_win_get_option(0, "diff") then
  -- 	vim.cmd([[diffput]])
  -- 	return
  -- end

  if in_oil_buffer() then
    return
  end

  oil.open_float()
end

-- vim.keymap.set("n", "<leader>e", toggle_oil, {
-- 	noremap = true,
-- 	desc = "toggle oil",
-- })

vim.keymap.set("n", "-", open_oil, {
  noremap = true,
  desc = "open oil",
})

return M
