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

    -- Diffview loads each file's diff buffers asynchronously (out-of-process
    -- `git show`). Cycling through files faster than those jobs finish tears
    -- down the buffer mid-load, so the completed load logs a harmless
    -- "Failed to create diff buffer" / "file buffer is invalid" error. The diff
    -- you land on is always correct — this just silences the popup noise. The
    -- error is still written to diffview's log (utils.err logs before notify).
    local ignore_patterns = {
      "Failed to create diff buffer",
      "The file buffer is invalid",
    }

    vim.notify = function(msg, level, opts)
      if type(msg) == "string" then
        for _, pattern in ipairs(ignore_patterns) do
          if msg:find(pattern, 1, true) then
            return
          end
        end
      end
      return notify(msg, level, opts)
    end
  end,
}
