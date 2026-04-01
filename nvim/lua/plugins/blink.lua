return {
  "saghen/blink.cmp",
  cond = not vim.g.vscode,
  event = "InsertEnter",
  version = "1.*",
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuOpen",
      callback = function()
        vim.b.copilot_suggestion_hidden = true
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "BlinkCmpMenuClose",
      callback = function()
        vim.b.copilot_suggestion_hidden = false
      end,
    })
  end,
  opts = {
    keymap = {
      preset = "none",
      ["<CR>"] = { "accept", "fallback" },
      ["<C-v>"] = {
        function(cmp)
          local copilot_ok, copilot = pcall(require, "copilot.suggestion")
          if not copilot_ok then
            return false
          end
          -- Dismiss blink menu so copilot suggestion can reappear
          vim.b.copilot_suggestion_hidden = false
          cmp.hide()
          -- Schedule to let copilot re-evaluate visibility
          vim.schedule(function()
            if copilot.is_visible() then
              copilot.accept()
            else
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
            end
          end)
          return true
        end,
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
