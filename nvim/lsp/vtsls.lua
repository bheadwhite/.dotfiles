---@brief
---
--- https://github.com/yioneko/vtsls
---
--- `vtsls` can be installed with npm:
--- ```sh
--- npm install -g @vtsls/language-server
--- ```
---
--- To configure a TypeScript project, add a
--- [`tsconfig.json`](https://www.typescriptlang.org/docs/handbook/tsconfig-json.html)
--- or [`jsconfig.json`](https://code.visualstudio.com/docs/languages/jsconfig) to
--- the root of your project.
---
--- ### Vue support
---
--- Since v3.0.0, the Vue language server requires `vtsls` to support TypeScript.
---
--- ```
--- -- If you are using mason.nvim, you can get the ts_plugin_path like this
--- -- For Mason v1,
--- -- local mason_registry = require('mason-registry')
--- -- local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server'
--- -- For Mason v2,
--- -- local vue_language_server_path = vim.fn.expand '$MASON/packages' .. '/vue-language-server' .. '/node_modules/@vue/language-server'
--- -- or even
--- -- local vue_language_server_path = vim.fn.stdpath('data') .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
--- local vue_language_server_path = '/path/to/@vue/language-server'
--- local vue_plugin = {
---   name = '@vue/typescript-plugin',
---   location = vue_language_server_path,
---   languages = { 'vue' },
---   configNamespace = 'typescript',
--- }
--- vim.lsp.config('vtsls', {
---   settings = {
---     vtsls = {
---       tsserver = {
---         globalPlugins = {
---           vue_plugin,
---         },
---       },
---     },
---   },
---   filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
--- })
--- ```
---
--- - `location` MUST be defined. If the plugin is installed in `node_modules`, `location` can have any value.
--- - `languages` must include vue even if it is listed in filetypes.
--- - `filetypes` is extended here to include Vue SFC.
---
--- You must make sure the Vue language server is setup. For example,
---
--- ```
--- vim.lsp.enable('vue_ls')
--- ```
---
--- See `vue_ls` section and https://github.com/vuejs/language-tools/wiki/Neovim for more information.
---
--- ### Monorepo support
---
--- `vtsls` supports monorepos by default. It will automatically find the `tsconfig.json` or `jsconfig.json` corresponding to the package you are working on.
--- This works without the need of spawning multiple instances of `vtsls`, saving memory.
---
--- It is recommended to use the same version of TypeScript in all packages, and therefore have it available in your workspace root. The location of the TypeScript binary will be determined automatically, but only once.

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
  local clients = vim.lsp.get_clients({ name = "vtsls", bufnr = bufnr })
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

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local client = get_client(bufnr)
  if not client then
    return
  end

  -- For document-level code actions like "add missing imports",
  -- we need to use make_position_params or construct params manually
  -- Using make_position_params with the buffer's window
  local win_id = 0
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      win_id = win
      break
    end
  end

  -- Use make_position_params which creates proper LSP params
  -- Then we'll override the range to be the whole document
  local params = vim.lsp.util.make_position_params(win_id, client.offset_encoding)

  -- Override range to cover entire document for document-level actions
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local last_line = math.max(0, line_count - 1)
  local last_line_text = vim.api.nvim_buf_get_lines(bufnr, last_line, last_line + 1, false)[1] or ""
  local last_line_length = #last_line_text

  params.range = {
    start = { line = 0, character = 0 },
    ["end"] = { line = last_line, character = last_line_length },
  }

  -- For "add missing imports", we don't need diagnostics in context
  -- The server will determine what to do based on the action type
  params.context = {
    only = { action },
    diagnostics = {}, -- Empty array - server determines actions from action type
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
    callback = function(ev)
      codeAction(ACTIONS.add_missing, ev.buf)
    end,
  })
end

return {
  cmd = { "vtsls", "--stdio" },
  init_options = {
    hostInfo = "neovim",
    preferences = {
      importModuleSpecifierPreference = "non-relative",
    },
  },
  settings = {
    preferences = {
      importModuleSpecifierPreference = "non-relative",
    },
    diagnostics = {
      ignoredCodes = diagnostic_filters,
    },
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
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
  root_dir = function(bufnr, on_dir)
    -- The project root is where the LSP can be started from
    -- As stated in the documentation above, this LSP supports monorepos and simple projects.
    -- We select then from the project root, which is identified by the presence of a package
    -- manager lock file.
    local root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
    -- Give the root markers equal priority by wrapping them in a table
    root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, { ".git" } } or vim.list_extend(root_markers, { ".git" })

    -- exclude deno
    if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
      return
    end

    -- We fallback to the current working directory if no project root is found
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

    on_dir(project_root)
  end,
}
