local function biome_lsp_or_prettier(bufnr)
  local has_prettier = vim.fs.find({
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.yml",
    ".prettierrc.yaml",
    ".prettierrc.json5",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.toml",
    "prettier.config.js",
    "prettier.config.cjs",
  }, { upward = true })[1]

  if has_prettier then
    return { "prettier", "prettierd" }
  end
  return { "biome" }
end

if vim.version().minor < 10 then
  return {}
end

return {
  "stevearc/conform.nvim",
  opts = {
    log_level = vim.log.levels.TRACE,
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
      css = biome_lsp_or_prettier,
      python = { "blackd" },
      go = { "gofmt" },
      lua = { "stylua" },
      javascript = biome_lsp_or_prettier,
      javascriptreact = biome_lsp_or_prettier,
      typescript = biome_lsp_or_prettier,
      typescriptreact = biome_lsp_or_prettier,
      html = biome_lsp_or_prettier,
      json = biome_lsp_or_prettier,
      jsonc = biome_lsp_or_prettier,
    },
    format_on_save = {
      timeout_ms = 3000,
    },
  },
}
