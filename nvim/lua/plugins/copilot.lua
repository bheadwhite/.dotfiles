if vim.version().minor < 10 then
  return {}
end

local ok_bdub, bdub = pcall(require, "bdub")
if ok_bdub and type(bdub.hyper_space_key) == "string" and bdub.hyper_space_key ~= "" then
  vim.keymap.set("v", bdub.hyper_space_key, function()
    vim.cmd("CopilotChat")
  end, { noremap = true, silent = true, desc = "Open CopilotChat" })

  vim.keymap.set("i", bdub.hyper_space_key, function()
    local copilot_ok, copilot = pcall(require, "copilot.suggestion")
    if copilot_ok then
      copilot.next()
    end
  end, { noremap = true, silent = true, desc = "Next Copilot suggestion" })
end

vim.keymap.set("n", "<C-v>", function()
  local feed_cr = function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
  end

  local sidekick_ok, sidekick = pcall(require, "sidekick.nes")
  if not sidekick_ok then
    feed_cr()
    return
  end

  if not sidekick.enabled then
    sidekick.enable()
    feed_cr()
    return
  end

  if sidekick.have() then
    sidekick.apply()
    return
  end

  sidekick.update()
  feed_cr()
end, { noremap = true, silent = true, desc = "Apply/trigger NES" })

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      server = {
        type = "nodejs",
        custom_server_filepath = vim.fn.stdpath("data")
          .. "/mason/packages/copilot-language-server/node_modules/@github/copilot-language-server/dist/language-server.js",
      },
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
          accept = "<C-M-;>",
        },
      },
    })
  end,
}
