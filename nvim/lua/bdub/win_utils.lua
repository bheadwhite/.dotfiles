local lua_utils = require("bdub.lua_utils")
local WinUtils = {}

-- local duplicateWindows = {}
--
-- vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
--   callback = function()
--     duplicateWindows = WinUtils.get_duplicate_win_buffers()
--   end,
-- })

function WinUtils.printWin(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local cursor = vim.api.nvim_win_get_cursor(win)
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)
  local position = vim.api.nvim_win_get_position(win)
  local config = vim.api.nvim_win_get_config(win)

  print("Window ID: " .. win)
  print("Buffer: " .. buf_name)
  print("Cursor Position: Row " .. cursor[1] .. ", Col " .. cursor[2])
  print("Size: " .. width .. "x" .. height)
  print("Position: Row " .. position[1] .. ", Col " .. position[2])
  print("Config: " .. vim.inspect(config))
  print("----------------------")
end

function WinUtils.get_duplicate_win_buffers()
  -- Get a list of all window IDs
  local windows = vim.api.nvim_list_wins()

  -- Create a table to keep track of buffer names
  local buffer_names = {}

  -- Iterate through each buffer
  for _, win in ipairs(windows) do
    local key = WinUtils.getDuplicateTableKeyFromWin(win)
    -- local buf_name = vim.api.nvim_buf_get_name(win)
    -- If the buffer name is already in the table, mark it as a duplicate
    if buffer_names[key] then
      buffer_names[key] = "duplicate"
    else
      buffer_names[key] = "unique"
    end
  end

  return buffer_names
end

-- key = tab_number .. buf_name
function WinUtils.getDuplicateTableKeyFromWin(win)
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
  local tab = vim.api.nvim_win_get_tabpage(win)
  local tab_number = vim.api.nvim_tabpage_get_number(tab)

  return tab_number .. name
end

-- function WinUtils.isWindowDuplicate(winToCheck)
--   -- return WinUtils.is_duplicate_win(winToCheck, duplicateWindows)
-- end

function WinUtils.set_window_backgrounds()
  -- Get the current window ID
  local current_win = vim.api.nvim_get_current_win()

  -- Get a list of all window IDs
  local windows = vim.api.nvim_list_wins()

  -- get duplicate win buffers
  local duplicates = WinUtils.get_duplicate_win_buffers()
  -- Iterate through each window
  for _, win in ipairs(windows) do
    local config = vim.api.nvim_win_get_config(win)
    local focusable = config.focusable

    if not focusable then
      goto continue
    end

    if win == current_win then
      -- Set highlight for the focused window
      vim.api.nvim_win_set_option(win, "winhighlight", "Normal:MyNormalColor")
    elseif WinUtils.is_duplicate_win(win, duplicates) then
      -- Set highlight for windows displaying duplicate buffers
      vim.api.nvim_win_set_option(win, "winhighlight", "Normal:DuplicateBuffer")
    else
      -- Set highlight for the unfocused windows
      vim.api.nvim_win_set_option(win, "winhighlight", "Normal:MyInactiveBufferColor")
    end

    ::continue::
  end
end

function WinUtils.get_win_buffers_with_duplicates()
  local duplicates_table = {}
  local windows = vim.api.nvim_list_wins()

  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local tab = vim.api.nvim_win_get_tabpage(win)
    local winKey = buf_name .. ">" .. tab

    if buf_name == "" then
    else
      if not duplicates_table[winKey] then
        duplicates_table[winKey] = { win }
      end

      table.insert(duplicates_table[winKey], win)
    end
  end

  for key, win_list in pairs(duplicates_table) do
    local deduped = lua_utils.deduplicate_list(win_list)
    duplicates_table[key] = deduped
  end

  return duplicates_table
end

function WinUtils.printWindows()
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    WinUtils.printWin(win)
  end
end

function WinUtils.printCurrentWindow()
  local win = vim.api.nvim_get_current_win()
  WinUtils.printWin(win)
end

function WinUtils.close_all_duplicates()
  local duplicates_table = WinUtils.get_win_buffers_with_duplicates()
  vim.print(duplicates_table)
  local currentTab = vim.api.nvim_get_current_tabpage()
  local didClose = false
  for _, win_list in pairs(duplicates_table) do
    if #win_list > 1 then
      for i = 2, #win_list do
        local win = win_list[i]
        local isCurrentTab = vim.api.nvim_win_get_tabpage(win) == currentTab
        if isCurrentTab then
          vim.print(win)
          didClose = true
          vim.api.nvim_win_close(win, true)
        end
      end
    end
  end

  if didClose then
    WinUtils.set_window_backgrounds()
  end

  return didClose
end

function WinUtils.is_duplicate_win(win, duplicateTable)
  local key = WinUtils.getDuplicateTableKeyFromWin(win)

  return duplicateTable[key] == "duplicate"
end

return WinUtils
