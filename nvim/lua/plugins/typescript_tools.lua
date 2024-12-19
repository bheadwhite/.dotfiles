local diagnostic_filters = {
  2311, -- Did you mean to write this in an async function?
  80006, -- This may be converted to an async function.
  80001, -- File is a CommonJS module; it may be converted to an ES module.
  7044, -- Parameter '{0}' implicitly has an '{1}' type, but a better type may be inferred from usage.
  7043, -- Variable '{0}' implicitly has an '{1}' type, but a better type may be inferred from usage.
}
-- filter codes list - https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json

return {
  "pmizio/typescript-tools.nvim",
  -- branch = "bugfix/202",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  config = function()
    local api = require("typescript-tools.api")
    local helpers = require("bdub.lsp_helpers")

    vim.tbl_add_reverse_lookup = function(tbl)
      for k, v in pairs(tbl) do
        tbl[v] = k
      end
    end

    require("typescript-tools").setup({
      on_attach = function(client, bufnr)
        client.server_capabilities = vim.tbl_deep_extend("force", client.server_capabilities, {
          documentFormattingProvider = false,
          documentRangeFormattingProvider = false,
        })
        vim.keymap.set("n", "gp", helpers.jump_to_parent_class, { noremap = true, silent = true })
        vim.keymap.set("n", "<leader>r", "<cmd>TSToolsRenameFile<CR>", { noremap = true, silent = true })

        helpers.on_attach(client, bufnr)
      end,
      settings = {
        tsserver_file_preferences = {
          importModuleSpecifierPreference = "non-relative",
        },
        jsx_close_tag = {
          enabled = true,
        },
      },
      handlers = {
        ["textDocument/publishDiagnostics"] = api.filter_diagnostics(diagnostic_filters),
      },
    })

    vim.keymap.set("n", "<leader>W", function()
      vim.cmd([[TSToolsOrganizeImports]])
    end, { noremap = true, silent = true })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("TS", { clear = true }),
      desc = "TS add missing imports",
      pattern = { "*.ts", "*.tsx" },
      callback = function()
        -- only call add missing imports if diagnostics are present and contain missing import code
        -- Check for diagnostics related to missing imports
        local diagnostics = vim.diagnostic.get(0) -- 0 means current buffer
        local has_missing_imports = false

        for _, diagnostic in ipairs(diagnostics) do
          if diagnostic.message:match("is not defined") or diagnostic.message:match("Cannot find name") then
            has_missing_imports = true
            break
          end
        end

        if has_missing_imports then
          pcall(vim.cmd, [[TSToolsAddMissingImports sync]])
        end
      end,
    })
  end,
}
