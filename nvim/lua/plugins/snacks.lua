return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    picker = {
      enabled = true,
      sources = {
        select = {
          win = {
            input = {
              keys = {
                ["<C-M-F14>"] = { "confirm", mode = { "n", "i" } },
              },
            },
            list = {
              keys = {
                ["<C-M-F14>"] = "confirm",
              },
            },
          },
        },
      },
    },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    scratch = {
      enabled = true,
      ft = function()
        return "markdown"
      end,
      win = {
        -- Vertical split on the far right instead of a floating modal.
        position = "right",
        -- Fraction of the editor width; height is ignored for a vsplit.
        width = 0.4,
      },
    },
    statuscolumn = { enabled = true },
    words = { enabled = false },
  },
  keys = {
    {
      "<leader>>",
      function()
        Snacks.scratch()
      end,
      desc = "scratch buffer",
    },
  },
}
