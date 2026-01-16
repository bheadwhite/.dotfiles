return {
  "rcarriga/nvim-notify",
  cond = not vim.g.vscode,
  config = function()
    notify = require("notify")

    notify.setup({
      stages = "static",
      render = "compact",
      timeout = 2000,
      top_down = false,
    })

    vim.notify = function(msg, log_level, opts)
      if msg == nil then
        return
      end

      notify(msg, log_level, opts)
    end
  end,
}
