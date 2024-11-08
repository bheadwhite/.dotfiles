local notify = require("notify")
local telescope = require("telescope.builtin")
local diagnostics = require("bdub.diagnostics")

local function add_desc(description, bufnr)
  local opts = { buffer = bufnr, remap = false }
  opts.desc = description

  return opts
end

local M = {}

function M.cursorToParent()
  --find constructor if none found then notify such and return
  local found = vim.fn.search("constructor(")

  if found == 0 then
    local exportFound = vim.fn.search("export", "bW")
    vim.cmd("normal! ww")

    if exportFound == 0 then
      notify.notify("No constructor, or export found", "error", { title = "Jump to Parent", timeout = 200 })
      return
    end
  end
end

function M.jump_to_parent_class()
  M.cursorToParent()

  local current_buf = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_position_params()
  local current_uri = vim.uri_from_bufnr(current_buf)

  -- Ensure the context is set correctly for the references request
  params.context = { includeDeclaration = true }

  vim.lsp.buf_request(0, "textDocument/references", params, function(err, result)
    --sort results by line number
    table.sort(result, function(a, b)
      return a.range.start.line > b.range.start.line
    end)

    if err ~= nil then
      print("Error during references request: " .. err.message)
      return
    end

    -- Filter out unwanted references and the current file's URI
    local filtered_result = {}
    local added_uris = {}
    for _, ref in ipairs(result or {}) do
      local uri = ref.uri or ""
      if
        not added_uris[uri]
        and uri ~= current_uri
        and not (string.find(uri, "%.test%.") or string.find(uri, "stories") or string.find(uri, "mock"))
      then
        table.insert(filtered_result, ref)
        added_uris[uri] = true
      end
    end

    if filtered_result and #filtered_result == 1 then
      local uri = filtered_result[1].uri
      local bufnr = vim.uri_to_bufnr(uri)
      local range = filtered_result[1].range

      -- Jump to the location of the single reference
      vim.lsp.util.jump_to_location({ uri = uri, range = range })
      vim.api.nvim_set_current_buf(bufnr)
    elseif result then
      vim.cmd("Glance references")
    else
      print("No references found.")
    end
  end)
end

function getUriFromDefinitionResult(result)
  if result == nil then
    return ""
  end

  if result.targetUri ~= nil then
    return result.targetUri
  end

  return result.uri ~= nil and result.uri or ""
end

function getRangeFromDefinitionResult(result)
  if result == nil then
    return nil
  end

  if result.targetRange ~= nil then
    return result.targetRange
  end

  return result.range ~= nil and result.range or nil
end

function M.on_attach(client, bufnr)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend("force", capabilities, client.capabilities, require("cmp_nvim_lsp").default_capabilities())

  client.capabilities = capabilities

  function isDefinitionResultLessThan2WithConstructor(ifYesCb, ifNoCb)
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, _ctx, _config)
      if err or not result or vim.tbl_isempty(result) then
        print("No definitions found")
        return
      end

      jump_to_config = nil

      if #result == 2 then
        for _, config in ipairs(result) do
          local uri = getUriFromDefinitionResult(config)
          local path = uri:gsub("^file://", "")
          local file = io.open(path, "r")
          if file then
            local content = file:read("*all")
            file:close()
            local range = getRangeFromDefinitionResult(config)

            if range == nil then
              return
            end

            local start_line = range.start.line + 1
            local end_line = range["end"].line + 1
            local lines = vim.split(content, "\n")
            local range_content = table.concat(vim.list_slice(lines, start_line, end_line), "\n")

            if range_content:match("constructor") then
              jump_to_config = config
            end
          end
        end
      end

      if result and #result == 1 then
        jump_to_config = result[1]
      end

      if jump_to_config then
        -- jump to the constructor in a new vsplit window
        vim.print(jump_to_config)
        local uri = getUriFromDefinitionResult(jump_to_config)

        local target_uri = vim.uri_to_fname(uri)
        local range = getRangeFromDefinitionResult(jump_to_config)
        if range == nil then
          return
        end

        local target_line = range.start.line + 1
        local target_character = range.start.character

        ifYesCb(target_uri, target_line, target_character)
      else
        ifNoCb()
      end
    end)
  end

  local function goToDefinition()
    local yesFn = function(target_uri, target_line, target_character)
      vim.cmd("e " .. target_uri)
      vim.api.nvim_win_set_cursor(0, { target_line, target_character })
    end
    local noFn = function()
      require("telescope.builtin").lsp_definitions({ show_line = false })
    end

    isDefinitionResultLessThan2WithConstructor(yesFn, noFn)
  end

  local function goToSplitDefinition()
    local yesFn = function(target_uri, target_line, target_character)
      vim.cmd("vsplit " .. target_uri)
      vim.api.nvim_win_set_cursor(0, { target_line, target_character })
    end
    local noFn = function(isOnlyOne)
      require("telescope.builtin").lsp_definitions({ show_line = false, jump_type = "vsplit" })
    end
    isDefinitionResultLessThan2WithConstructor(yesFn, noFn)
  end

  local function goToTabDefinition()
    telescope.lsp_definitions({ show_line = false, jump_type = "tab" })
  end

  local function lspFinder()
    --dont fire events BufLeave or WinLeave
    vim.cmd("Glance references")
  end

  local function goToSplitReferences()
    telescope.lsp_references({ show_line = false, jump_type = "vsplit", include_declaration = false })
  end

  local function goToTypeDefinition()
    telescope.lsp_type_definitions({ show_line = false })
  end

  local function openTypeInSplit()
    telescope.lsp_type_definitions({ show_line = false, jump_type = "vsplit" })
  end

  local function goToTabTypeDefinition()
    telescope.lsp_type_definitions({ show_line = false, jump_type = "tab" })
  end

  function formatDiagnostic(d)
    message = ""
    if d.source then
      if d.code then
        message = message .. " [ " .. d.source .. " - " .. d.code .. " ]"
      else
        message = message .. " [ " .. d.source .. " ]"
      end
    end

    message = message .. " " .. d.message

    return message
  end

  local current_line_diagnostics = nil

  local function showLineDiagnostic(d)
    if not d then
      return
    end

    current_line_diagnostics = d.lnum

    notify.dismiss()
    notify.notify(formatDiagnostic(d), "info", {
      title = "Diagnostic",
      timeout = 5000,
      on_close = function()
        current_line_diagnostics = nil
      end,
      keep = function()
        local line_nr = vim.api.nvim_win_get_cursor(0)[1] - 1 -- Get zero-indexed line number
        if current_line_diagnostics ~= line_nr then
          return false
        end

        local line_diagnostics = vim.diagnostic.get(0, { lnum = line_nr })
        if #line_diagnostics > 0 then
          showLineDiagnostic(line_diagnostics[1])
        end

        return false
      end,
    })
  end

  local normal_keymaps = {
    { "gi", goToDefinition, "go to defintion" },
    { "gI", goToSplitDefinition, "open definition in split" },
    { "g<tab>i", goToTabDefinition, "go to definition in new tab" },
    { "gr", lspFinder, "lsp finder" },
    { "gR", goToSplitReferences, "go to references v_split" },
    { "gt", goToTypeDefinition, "go to type definition" },
    { "gT", openTypeInSplit, "open type in split" },
    { "g<tab>t", goToTabTypeDefinition, "go to type definition in new tab" },
    {
      "gd",
      function()
        vim.diagnostic.open_float(0, { scope = "line" })
      end,
      "open diagnostic float",
    },
    {
      "<M-S-l>",
      function()
        local d = vim.diagnostic.get_next()
        if d then
          showLineDiagnostic(d)
        end
        vim.diagnostic.goto_next({ float = false })
      end,
      "next diagnostic",
    },
    {
      "<M-S-h>",
      function()
        local d = vim.diagnostic.get_prev()
        if d then
          showLineDiagnostic(d)
        end
        vim.diagnostic.goto_prev({ float = false })
      end,
      "prev diagnostic",
    },
    { "<leader>vd", vim.diagnostic.open_float, "view diagnostic" },
    { "<leader>vs", vim.lsp.buf.workspace_symbol, "workspace symbols" },
    { "<leader>.", vim.lsp.buf.code_action, "code action" },
    { "<C-A-n>", vim.lsp.buf.rename, "rename symbol" },
    {
      "gh",
      function()
        vim.lsp.buf.hover()
      end,
      "hover",
    },
    {
      "K",
      function()
        -- vim.cmd([[Lspsaga peek_type_definition]])
      end,
      "peek type definition",
    },
    { "gH", vim.lsp.buf.signature_help, "signature help" },
  }

  diagnostics.setDiagnosticColorOverrides()

  for _, value in ipairs(normal_keymaps) do
    vim.keymap.set("n", value[1], value[2], add_desc(value[3], bufnr))
  end

  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, add_desc("signature help", bufnr))
end

return M
