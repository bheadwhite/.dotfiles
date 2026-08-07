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
  local source_win = vim.api.nvim_get_current_win()
  local win_count = #vim.api.nvim_tabpage_list_wins(prev_tab)

  -- Create new tab and move buffer there
  vim.cmd("tabnew")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_cursor(0, cursor_pos)

  -- Close the source window in the previous tab, but only when it was one of
  -- several splits (closing the sole window would take the whole tab with it).
  -- Then equalize the remaining splits in that tab (the equivalent of <C-w>=),
  -- run in the previous tab's context so we don't have to leave the zoom tab.
  if win_count > 1 and vim.api.nvim_win_is_valid(source_win) then
    vim.api.nvim_win_close(source_win, { force = true })
    local remaining = vim.api.nvim_tabpage_list_wins(prev_tab)
    if #remaining > 0 then
      vim.api.nvim_win_call(remaining[1], function()
        vim.cmd("wincmd =")
      end)
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
