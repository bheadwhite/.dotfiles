local diagnostic_filters = {
  2311, -- Did you mean to write this in an async function?
  80006, -- This may be converted to an async function.
  80001, -- File is a CommonJS module; it may be converted to an ES module.
  7044, -- Parameter '{0}' implicitly has an '{1}' type, but a better type may be inferred from usage.
  7043, -- Variable '{0}' implicitly has an '{1}' type, but a better type may be inferred from usage.
}
-- filter codes list - https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json

return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/typescript-language-server", "--stdio" },
  filetypes = { "ts", "tsx", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json" },
  init_options = {
    preferences = {
      importModuleSpecifierPreference = "non-relative",
    },
  },
  settings = {
    diagnostics = {
      ignoredCodes = diagnostic_filters,
    },
  },
  on_attach = function(client, bufnr)
    -- vim.keymap.set("n", "gp", helpers.jumpToTypescriptReference, { noremap = true, silent = true })
    -- <cmd>lua require('helpers').jumpToTypescriptReference()<CR>"
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gp", "<cmd>lua require('bdub.lsp_helpers').jumpToTypescriptReference()<CR>", {
      noremap = true,
      silent = true,
      desc = "Jump to TypeScript reference",
    })
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>r", "<cmd>TSToolsRenameFile<CR>", { noremap = true, silent = true, desc = "Rename file" })
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>W", [[<cmd>TSToolsOrganizeImports<CR>]], { noremap = true, silent = true })
    --
    --
    function renameFile()
      local source_file = vim.api.nvim_buf_get_name(0)
      vim.ui.input({
        prompt = "Rename: ",
        completion = "file",
        default = source_file,
      }, function(target)
        if not target or target == "" then
          return
        end

        local params = {
          command = "_typescript.applyRenameFile",
          arguments = {
            {
              sourceUri = source_file,
              targetUri = target,
            },
          },
          title = "",
        }

        vim.lsp.util.rename(source_file, target)
        vim.lsp.buf_request(bufnr, "workspace/executeCommand", params)
      end)

      -- vim.lsp.buf.execute_command(params)
    end

    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>r", "<cmd>lua renameFile()<CR>", { noremap = true, silent = true, desc = "Rename file" })

    require("bdub.lsp_helpers").on_attach(client, bufnr)
  end,
}

-- jsx_close_tag = {
--   enabled = true,
-- },
