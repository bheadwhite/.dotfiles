return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/biome" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json" },
  root_markers = { ".biomeconfig.json", "biome.config.js", "biome.config.ts", "biome.json" },
  settings = {
    biome = {
      organizeImports = {
        enabled = false, -- Disable automatic import organization
      },
    },
  },
  handlers = {
    ["workspace/executeCommand"] = function(err, result, ctx, config)
      -- Suppress "setContext" command not found errors from Biome
      -- This is a known issue where Biome doesn't support the setContext command
      if err then
        local err_msg = err.message or tostring(err) or ""
        if err_msg:match("setContext") or err_msg:match("Command setContext not found") then
          return
        end
      end
      -- Fall back to default handler for other commands
      if vim.lsp.handlers["workspace/executeCommand"] then
        vim.lsp.handlers["workspace/executeCommand"](err, result, ctx, config)
      end
    end,
  },
  on_attach = require("bdub.lsp_helpers").on_attach,
}
