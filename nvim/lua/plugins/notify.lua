return {
  "rcarriga/nvim-notify",
  opts = {
    stages = "static",
    render = "wrapped-compact",
    timeout = 1000,
  },
  config = function()
    vim.notify = require("notify")
  end,
}
