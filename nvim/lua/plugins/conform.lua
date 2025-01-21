-- local biomefmt = { "biome" }
local js_formatter = "prettierd" -- "prettierd" or "biome"
-- local js_formatter = "biome" -- "prettierd" or "biome"

if vim.version().minor < 10 then
  return {}
end

return {
  "stevearc/conform.nvim",
  opts = {
    -- log_level = vim.log.levels.DEBUG,
    formatters = {
      blackd = {
        command = "blackd-client",
        args = {
          "--line-length",
          "120",
        },
        stdin = true,
        require_cwd = false,
        exit_codes = { 0 },
      },
      black = {
        prepend_args = {
          "--line-length",
          "120",
        },
      },
    },
    formatters_by_ft = {
      css = { js_formatter },
      python = { "blackd" },
      go = { "gofmt" },
      lua = { "stylua" },
      javascript = { js_formatter },
      javascriptreact = { js_formatter },
      typescript = { js_formatter },
      typescriptreact = { js_formatter },
      html = { "prettierd" },
      json = { js_formatter },
    },
    format_on_save = {
      timeout_ms = 3000,
    },
  },
}
