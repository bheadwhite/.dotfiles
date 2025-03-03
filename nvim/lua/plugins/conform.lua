-- local biomefmt = { "biome" }
local function detect_formatter()
  local biome_files = { "biome.json", ".biome.json" }
  local prettier_files = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.js",
    "prettier.config.js",
    "prettier.config.cjs",
    "prettier.config.mjs",
  }

  local cwd = vim.fn.getcwd()
  local found_biome, found_prettier = false, false

  -- Check for Biome config files
  for _, file in ipairs(biome_files) do
    if vim.fn.filereadable(cwd .. "/" .. file) == 1 then
      found_biome = true
      break
    end
  end

  -- Check for Prettier config files
  for _, file in ipairs(prettier_files) do
    if vim.fn.filereadable(cwd .. "/" .. file) == 1 then
      found_prettier = true
      break
    end
  end

  -- Return detected formatter
  if found_biome and found_prettier then
    return "biome"
  elseif found_biome then
    return "biome"
  elseif found_prettier then
    return "prettier"
  else
    return nil
  end
end

-- Example usage:
local formatter = detect_formatter()
local js_formatter = "prettierd" -- "prettierd" or "biome"

if formatter then
  if formatter == "biome" then
    js_formatter = "biome"
  elseif formatter == "prettier" then
    js_formatter = "prettierd"
  end
else
end

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
