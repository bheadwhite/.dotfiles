-- Enable/disable switch for the agentic.nvim task-loop plugin.
--
-- agentic.nvim is OFF by default. Whether it loads is decided at startup by
-- lazy.nvim reading `is_enabled()` (see lua/plugins/taskloop.lua), so toggling
-- only takes effect on the next nvim launch. The state lives in a marker file
-- rather than a dotfile edit, so it persists across sessions and needs no commit.
--
-- Commands (defined here so they exist even while the plugin is disabled):
--   :AgenticEnable   create the marker  -> loads on next launch
--   :AgenticDisable  remove the marker  -> stays off on next launch
--   :AgenticToggle   flip it
local M = {}

M.marker = vim.fn.stdpath("state") .. "/agentic.enabled"

function M.is_enabled()
  return vim.fn.filereadable(M.marker) == 1
end

local function set(enabled)
  if enabled then
    vim.fn.mkdir(vim.fn.fnamemodify(M.marker, ":h"), "p")
    vim.fn.writefile({}, M.marker)
  elseif M.is_enabled() then
    vim.fn.delete(M.marker)
  end
  vim.notify(
    ("agentic.nvim %s — restart nvim to take effect"):format(enabled and "enabled" or "disabled"),
    vim.log.levels.INFO
  )
end

function M.setup()
  vim.api.nvim_create_user_command("AgenticEnable", function()
    set(true)
  end, { desc = "Enable agentic.nvim (loads on next nvim launch)" })

  vim.api.nvim_create_user_command("AgenticDisable", function()
    set(false)
  end, { desc = "Disable agentic.nvim (stays off on next nvim launch)" })

  vim.api.nvim_create_user_command("AgenticToggle", function()
    set(not M.is_enabled())
  end, { desc = "Toggle agentic.nvim on/off (takes effect on next launch)" })
end

return M
