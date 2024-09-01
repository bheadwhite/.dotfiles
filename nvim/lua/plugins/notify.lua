return {
  "rcarriga/nvim-notify",
  config = function()
    notify = require("notify")

    notify.setup({
      stages = "static",
      render = "compact",
      timeout = 2000,
      top_down = false,
    })

    vim.notify = notify
  end,
}
