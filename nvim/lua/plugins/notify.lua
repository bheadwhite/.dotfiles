return {
  "rcarriga/nvim-notify",
  cond = not vim.g.vscode,
  config = function()
    local notify = require("notify")

    notify.setup({
      stages = "static",
      render = "compact",
      timeout = 2000,
      top_down = false,
    })

    vim.notify = notify
  end,
}
