if vim.version().minor < 10 then
  return {}
end

local hyper_key = require("bdub.globals").hyper_space_key

local triggerNes = function()
  local copilotClient = vim.lsp.get_clients({ name = "copilot" })[1]
  return require("copilot-lsp.nes").request_nes(copilotClient)
end

local isNesActive = function()
  return vim.b[vim.api.nvim_get_current_buf()].nes_state ~= nil
end

vim.keymap.set({ "i", "n" }, hyper_key, function()
  -- Check if suggestions are already visible
  require("copilot.suggestion").next()

  if not isNesActive() then
    triggerNes()
  end

end, { noremap = true, silent = true })

vim.keymap.set("v", hyper_key, function()
  vim.cmd("CopilotChat")
end, { noremap = true, silent = true })


return {
  "zbirenbaum/copilot.lua",
  dependencies = {
    "copilotlsp-nvim/copilot-lsp"
  },
  init = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_nes_debounce = 500
  end,
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      panel = {
        enabled = false,
      },
      nes = {
        enabled = true,
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
