local lsp = require('lspconfig')

local luaformat = require "lsp.formatters.lua-format"
local prettier_d = require "lsp.formatters.prettier_d"
local eslint_d = require "lsp.linters.eslint_d"

local formatter = prettier_d

local linter = eslint_d

local languages = {
  lua = { luaformat },
  typescript = { formatter, linter },
  javascript = { formatter, linter },
  typescriptreact = { formatter, linter },
  ['typescript.tsx'] = { formatter, linter },
  javascriptreact = { formatter, linter },
  ['javascript.jsx'] = { formatter, linter },
  vue = { formatter, linter },
  yaml = { formatter },
  json = { formatter },
  html = { formatter },
  scss = { formatter },
  css = { formatter },
  markdown = { formatter },
}

--lspconfig function
return function()
  return {
    root_dir = function(fname)
        -- [[ if not eslint_config_exists() then
          -- print 'eslint configuration not found'
          -- return nil
        -- end]]
        -- check if eslint_d installed globally!
        -- return lsp.util.root_pattern("package.json", ".git", vim.fn.getcwd())
        -- return getcwd()
       local cwd = lsp.util.root_pattern("tsconfig.json")(fname) or
                 lsp.util.root_pattern(".eslintrc.json", ".git")(fname) or
                 lsp.util.root_pattern("package.json", ".git/", ".zshrc")(fname);
       return cwd
      end,
    filetypes = vim.tbl_keys(languages),
    init_options = {
      documentFormatting = true,
    },
    settings = {
      rootMarkers = { "package.json", ".git" },
      lintDebounce = 500,
      languages = languages
    },
  }
end
