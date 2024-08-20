local hyper_key = require("bdub.globals").hyper_space_key
vim.keymap.set({ "i" }, hyper_key, function()
  require("copilot.suggestion").next()
end, { noremap = true, silent = true })

vim.keymap.set("v", hyper_key, function()
  vim.cmd("CopilotChat")
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
        enabled = true,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-V>",
        },
      },
    })
  end,
}
