if vim.version().minor < 10 then
  return {}
end

-- Safe access to hyper_space_key for CopilotChat
local ok_bdub, bdub = pcall(require, "bdub")
if ok_bdub and type(bdub.hyper_space_key) == "string" and bdub.hyper_space_key ~= "" then
  vim.keymap.set("v", bdub.hyper_space_key, function()
    vim.cmd("CopilotChat")
  end, { noremap = true, silent = true, desc = "Open CopilotChat" })
end

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
