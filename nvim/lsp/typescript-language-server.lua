local diagnostic_filters = {
  2311, -- Did you mean to write this in an async function?
  80006, -- This may be converted to an async function.
  80001, -- File is a CommonJS module; it may be converted to an ES module.
  7044, -- Parameter '{0}' implicitly has an '{1}' type, but a better type may be inferred from usage.
  7043, -- Variable '{0}' implicitly has an '{1}' type, but a better type may be inferred from usage.
}
-- filter codes list - https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
--
--
local ACTIONS = {
  sort = "source.sortImports.ts",
  add_missing = "source.addMissingImports.ts",
  remove = "source.removeUnused.ts",
}

local function get_client(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ name = "typescript-language-server", bufnr = bufnr })
  if not clients or #clients == 0 then
    return nil
  end
  return clients[1]
end

local function apply_code_actions(result, client)
  if not result then
    return
  end
  for _, res in pairs(result) do
    if res.result then
      for _, r in ipairs(res.result) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
        else
          client.exec_command(r.command)
        end
      end
    end
  end
end

local function codeAction(action, bufnr)
  if not action then
    return
  end

  local client = get_client(bufnr)
  if not client then
    return
  end
  local params = vim.lsp.util.make_range_params(nil, "utf-8")
  params.context = {
    only = { action },
  }

  pcall(function()
    local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
    if result then
      apply_code_actions(result, client)
    end
  end)
end

local function add_autoimport_cmd()
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("ts_fix_imports", { clear = true }),
    desc = "Add missing imports and remove unused imports for TS",
    pattern = { "*.ts", "*.tsx" },
    callback = function()
      codeAction(ACTIONS.add_missing, 0)
    end,
  })
end

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
    add_autoimport_cmd()

    require("bdub.lsp_helpers").on_attach(client, bufnr)
  end,
}

-- jsx_close_tag = {
--   enabled = true,
-- },
