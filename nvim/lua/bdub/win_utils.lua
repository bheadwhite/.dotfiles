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

-- key = tab_number .. buf_name
function WinUtils.getDuplicateTableKeyFromWin(win)
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
  local tab = vim.api.nvim_win_get_tabpage(win)
  local tab_number = vim.api.nvim_tabpage_get_number(tab)

  return tab_number .. name
end

function WinUtils.set_window_backgrounds()
  -- Get the current window ID
  local current_win = vim.api.nvim_get_current_win()

  -- Get a list of all window IDs
  local windows = vim.api.nvim_list_wins()

  -- if any window is part of a tab with a bufname that start with the word "diffview", lets filter that out
  local execption_windows = {}
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)

    if buf_name == "" then
      table.insert(execption_windows, win)
      goto continue
    end

    if string.find(buf_name, "diffview") then
      -- iterate over all the windows in this tab and add them to the diffview_windows table
      local tab = vim.api.nvim_win_get_tabpage(win)
      local tab_windows = vim.api.nvim_tabpage_list_wins(tab)
      for _, tab_win in ipairs(tab_windows) do
        table.insert(execption_windows, tab_win)
      end
      break
    end

    ::continue::
  end

  -- remove the diffview windows from the windows table
  for _, win in ipairs(execption_windows) do
    for i, w in ipairs(windows) do
      if w == win then
        table.remove(windows, i)
        break
      end
    end
  end

  -- get duplicate win buffers
  -- local duplicateStore = WinUtils.get_buffer_duplicate_store()
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
    -- elseif WinUtils.is_win_duplicate_from_store(win, duplicateStore) then
    --   -- Set highlight for windows displaying duplicate buffers
    --   vim.api.nvim_win_set_option(win, "winhighlight", "Normal:DuplicateBuffer")
    else
      -- Set highlight for the unfocused windows
      vim.api.nvim_win_set_option(win, "winhighlight", "Normal:MyInactiveBufferColor")
    end

    ::continue::
  end
end

function WinUtils.is_win_duplicate_from_store(win, duplicateStore)
  local key = WinUtils.getDuplicateTableKeyFromWin(win)

  return duplicateStore[key] == "duplicate"
end

function WinUtils.is_win_duplicate(win)
  return WinUtils.is_win_duplicate_from_store(win, WinUtils.get_buffer_duplicate_store())
end

-- used in set_window_backgrounds
-- @return table of buffer names with tab number appended as key
-- the value is either "duplicate" or "unique"
-- this is a quick lookup of duplicate buffers
function WinUtils.get_buffer_duplicate_store()
  -- Get a list of all window IDs
  local windows = vim.api.nvim_list_wins()

  -- Create a table to keep track of buffer names
  local duplicateStore = {}

  -- Iterate through each buffer
  for _, win in ipairs(windows) do
    local config = vim.api.nvim_win_get_config(win)
    if not config.focusable then
      goto continue
    end

    local key = WinUtils.getDuplicateTableKeyFromWin(win)
    -- local buf_name = vim.api.nvim_buf_get_name(win)
    -- If the buffer name is already in the table, mark it as a duplicate
    if duplicateStore[key] then
      duplicateStore[key] = "duplicate"
    else
      duplicateStore[key] = "unique"
    end

    ::continue::
  end

  return duplicateStore
end

-- used in close_all_duplicates method
--@return table of lists of window ids
-- key = <BUF_NAME> > <TAB_NUMBER>
-- value = list of window ids {win1, win2, ...}
-- if length of lists > 1, then it has duplicates
-- this is used to keep track of winids that are duplicates
function WinUtils.get_win_buffers_with_duplicates()
  local duplicateWindows = {}
  local windows = vim.api.nvim_list_wins()

  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local tab = vim.api.nvim_win_get_tabpage(win)
    local config = vim.api.nvim_win_get_config(win)

    if not config.focusable then
      goto continue
    end

    local winKey = buf_name .. ">" .. tab

    if buf_name == "" then
    else
      if not duplicateWindows[winKey] then
        duplicateWindows[winKey] = { win }
      end

      table.insert(duplicateWindows[winKey], win)
    end

    ::continue::
  end

  for key, win_list in pairs(duplicateWindows) do
    local deduped = lua_utils.deduplicate_list(win_list)
    duplicateWindows[key] = deduped
  end

  return duplicateWindows
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

function WinUtils.close_current_tab_duplicate_windows()
  local duplicates_table = WinUtils.get_win_buffers_with_duplicates()
  local currentTab = vim.api.nvim_get_current_tabpage()
  local didClose = false
  for _, win_list in pairs(duplicates_table) do
    if #win_list > 1 then
      for i = 2, #win_list do
        local win = win_list[i]
        local isCurrentTab = vim.api.nvim_win_get_tabpage(win) == currentTab
        if isCurrentTab then
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

return WinUtils
