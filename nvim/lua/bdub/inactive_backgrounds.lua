vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  callback = function()
    local utils = require("bdub.win_utils")
    utils.set_window_backgrounds()
  end,
})

-- Call the function to apply the highlights initially

local zoomed = false
vim.keymap.set("n", "<leader>z", function()
  local buf = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local prev_tab = vim.api.nvim_get_current_tabpage()
  
  -- Create new tab and move buffer there
  vim.cmd("tabnew")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  
  -- Close the window in previous tab that shows this buffer
  local prev_wins = vim.api.nvim_tabpage_list_wins(prev_tab)
  for _, win in ipairs(prev_wins) do
    if vim.api.nvim_win_get_buf(win) == buf then
      vim.api.nvim_win_close(win, { force = true })
      break
    end
  end
  
  -- Move the new tab to the end
  vim.cmd("tabmove")
end, { noremap = true, silent = true, desc = "zoom in" })

return {
  get_zoom = function()
    return zoomed
  end,
}
