if vim.version().minor < 10 then
  return {}
end

local hyper_key = require("bdub.globals").hyper_space_key
vim.keymap.set({ "i" }, hyper_key, function()
  -- Check if suggestions are already visible
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").next()
  else
    -- Try to trigger new suggestions
    vim.print('requesting new suggestions...')

    -- Method 1: Try using the internal API to request suggestions
    pcall(function()
      local copilot = require("copilot.suggestion")
      copilot.dismiss() -- Clear any existing state

      -- Simulate text change to trigger suggestions
      local pos = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_get_current_line()

      -- Insert and immediately delete a space to trigger Copilot
      vim.api.nvim_set_current_line(line .. " ")
      vim.schedule(function()
        vim.api.nvim_set_current_line(line)
        vim.api.nvim_win_set_cursor(0, pos)

        -- Small delay then try to get suggestions
        vim.defer_fn(function()
          if copilot.is_visible() then
            vim.print('suggestions now visible!')
          else
            vim.print('no suggestions available')
          end
        end, 200)
      end)
    end)
  end
end, { noremap = true, silent = true })

vim.keymap.set("v", hyper_key, function()
  vim.cmd("CopilotChat")
end, { noremap = true, silent = true })

vim.keymap.set("i", "<C-v>", function()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
  end
end, { noremap = true, silent = true })

return {
  "zbirenbaum/copilot.lua",
  init = function()
    vim.g.copilot_no_tab_map = true
  end,
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-M-;>",
        },
      },
    })
  end,
}
