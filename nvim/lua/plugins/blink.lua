return {
  "saghen/blink.cmp",
  cond = not vim.g.vscode,
  event = "InsertEnter",
  version = "1.*",
  opts = {
    keymap = {
      preset = "none",
      ["<CR>"] = { "accept", "fallback" },
      ["<C-v>"] = {
        function(cmp)
          local copilot_ok, copilot = pcall(require, "copilot.suggestion")
          if copilot_ok and copilot.is_visible() then
            copilot.accept()
            return true
          end
          return false
        end,
        "accept",
        "fallback",
      },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<M-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<C-d>"] = { "scroll_documentation_up", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<M-k>"] = { "select_prev", "fallback" },
      ["<M-j>"] = { "select_next", "fallback" },
    },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },

    sources = {
      default = { "lsp" },
    },

    completion = {
      accept = {
        auto_brackets = { enabled = true },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },
    },

    signature = {
      enabled = true,
    },
  },
}
