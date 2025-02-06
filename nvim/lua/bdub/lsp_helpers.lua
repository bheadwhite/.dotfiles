local notify = require("notify")
local telescope = require("telescope.builtin")

local function add_desc(description, bufnr)
  local opts = { buffer = bufnr, remap = false }
  opts.desc = description

  return opts
end

local M = {
  glanceState = {
    findTests = false,
  },
}

function M.showFilterNotify()
  local message = ""
  if M.glanceState.findTests then
    message = "Showing ALL ([leader+t] to filter)"
  else
    message = "Filtering Tests, Mocks, logs and Stories ([leader+t] to clear)"
  end

  notify.notify(message, (M.glanceState.findTests and "info" or "warn"), { title = "Filtering results" })
end

M.changeGlanceState = function()
  M.glanceState.findTests = not M.glanceState.findTests
  M.showFilterNotify()
end

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

function M.on_attach(client, attached_bufnr)
  local cmp_capabilities = {}
  -- Safely attempt to load cmp_nvim_lsp capabilities
  local status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status then
    cmp_capabilities = cmp_nvim_lsp.default_capabilities()
  end

  -- Ensure client.capabilities exists and safely extend capabilities
  local base_capabilities = vim.lsp.protocol.make_client_capabilities()
  client.capabilities = vim.tbl_deep_extend(
    "force",
    base_capabilities, -- Base capabilities
    client.capabilities or {}, -- Existing client capabilities
    cmp_capabilities -- cmp_nvim_lsp capabilities
  )

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

  function unpackResultUri(result)
    local uri = result.uri or result.targetUri
    if uri == nil then
      vim.print("No uri found in result")
      vim.print(result)
      return ""
    end
    return vim.uri_to_fname(uri)
  end

  function unpackResultRange(result)
    return result.range or result.targetRange
  end

  function getSingleResult(result)
    filtered_result = {}

    if not M.glanceState.findTests and result ~= nil then
      for _, res in ipairs(result) do
        local uri = unpackResultUri(res)
        if not (string.find(uri, "%.test%.") or string.find(uri, "stories") or string.find(uri, "mock") or string.find(uri, "logging")) then
          table.insert(filtered_result, res)
        end
      end
    end

    if #filtered_result == 1 then
      local target_uri = unpackResultUri(filtered_result[1])
      local range = unpackResultRange(filtered_result[1])

      return filtered_result, target_uri, range
    end

    return filtered_result, nil, nil
  end

  local normal_keymaps = {
    { "gd", goToDefinition, "go to defintion" },
    { "gD", goToSplitDefinition, "open definition in split" },
    { "g<tab>i", goToTabDefinition, "go to definition in new tab" },
    {
      "gi",
      function()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result) -- err, result, ctx, config)
          local filtered, target_uri, range = getSingleResult(result)

          if target_uri and range then
            local col = range.start.character
            --open in split
            M.showFilterNotify()
            vim.cmd("e " .. target_uri)
            vim.api.nvim_win_set_cursor(0, { range.start.line + 1, col })
          elseif err or not result or vim.tbl_isempty(result) then
            goToDefinition()
          else
            telescope.lsp_implementations({ show_line = false })
          end
        end)
      end,
      "go to implemenation",
    },
    {
      "gI",
      function()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result, ctx, config)
          local filtered, target_uri, range = getSingleResult(result)

          if target_uri and range then
            local col = range.start.character
            --open in split
            M.showFilterNotify()
            vim.cmd("vsplit " .. target_uri)
            vim.api.nvim_win_set_cursor(0, { range.start.line + 1, col })
          elseif err or not result or vim.tbl_isempty(result) then
            goToSplitDefinition()
          else
            telescope.lsp_implementations({ show_line = false, jump_type = "vsplit" })
          end
        end)
      end,
      "open implemenation in split",
    },
    { "gr", lspFinder, "lsp finder" },
    {
      "gR",
      function()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, "textDocument/references", params, function(err, result, ctx, config)
          local results = getSingleResult(result)

          local pickers = require("telescope.pickers")
          local finders = require("telescope.finders")
          local previewers = require("telescope.previewers")
          local conf = require("telescope.config").values
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")

          pickers
            .new({}, {
              prompt_title = "References",
              finder = finders.new_table({
                results = results,
                entry_maker = function(entry)
                  return {
                    value = entry,
                    display = entry.uri:gsub("file://", ""), -- Clean up the display path
                    ordinal = entry.uri,
                    path = vim.uri_to_fname(entry.uri), -- Convert URI to file path
                    range = entry.range, -- Pass range data for future use
                  }
                end,
              }),

              previewer = previewers.new_buffer_previewer({
                define_preview = function(self, entry)
                  local path = entry.path
                  local range = entry.range

                  -- Load the file into the preview buffer
                  if not vim.loop.fs_stat(path) then
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "File not found: " .. path })
                    return
                  end

                  -- Read the file content into the buffer
                  local lines = vim.fn.readfile(path)
                  vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

                  -- Set filetype for syntax highlighting
                  local filetype = vim.filetype.match({ filename = path }) or "text"
                  vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", filetype)

                  -- Highlight the specific line
                  local line_to_highlight = range.start.line
                  local total_lines = vim.api.nvim_buf_line_count(self.state.bufnr)

                  if line_to_highlight < total_lines then
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, "TelescopePreviewLine", line_to_highlight, 0, -1)

                    -- Use a single defer to set the cursor and center the window
                    vim.defer_fn(function()
                      vim.api.nvim_win_set_cursor(self.state.winid, { line_to_highlight + 1, 0 })

                      -- Center the preview window based on its height
                      local win_height = vim.api.nvim_win_get_height(self.state.winid)
                      local top_line = math.max(0, line_to_highlight - math.floor(win_height / 2))
                      vim.api.nvim_win_call(self.state.winid, function()
                        vim.fn.winrestview({ topline = top_line + 1 })
                      end)
                    end, 10) -- Small delay to ensure the buffer is ready
                  else
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "Error: Line out of range" })
                  end
                end,
              }),
              sorter = conf.generic_sorter({}),
              attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                  local selection = action_state.get_selected_entry()
                  actions.close(prompt_bufnr)

                  -- Open the file and jump to the related position
                  local path = selection.path
                  local range = selection.range

                  -- Open the file
                  vim.cmd("vsp " .. vim.fn.fnameescape(path))

                  -- Move cursor to the specified position
                  vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })

                  -- Center the cursor on the screen
                  vim.defer_fn(function()
                    local win_height = vim.api.nvim_win_get_height(0)
                    local total_lines = vim.api.nvim_buf_line_count(0)

                    -- Calculate top line to center the cursor
                    local line_to_highlight = range.start.line
                    local top_line = math.max(0, line_to_highlight - math.floor(win_height / 2))
                    vim.fn.winrestview({ topline = top_line + 1 })

                    -- Additional safety check to ensure proper cursor centering
                    if line_to_highlight < total_lines then
                      vim.api.nvim_win_set_cursor(0, { line_to_highlight + 1, range.start.character })
                    end
                  end, 10) -- Short delay to ensure window dimensions are finalized
                end)
                return true
              end,
            })
            :find()
        end)
      end,
      "go to references v_split",
    },
    { "gt", goToTypeDefinition, "go to type definition" },
    { "gT", openTypeInSplit, "open type in split" },
    { "g<tab>t", goToTabTypeDefinition, "go to type definition in new tab" },
    {
      "g<leader>",
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
    { "<A-h>", vim.diagnostic.open_float, "view diagnostic" },
    { "<leader>vs", vim.lsp.buf.workspace_symbol, "workspace symbols" },
    { "<leader>.", vim.lsp.buf.code_action, "code action" },
    { "<C-A-n>", vim.lsp.buf.rename, "rename symbol" },
    { "<leader>t", M.changeGlanceState, "toggle glance filter" },
    {
      "gh",
      function()
        vim.lsp.buf.hover()
      end,
      "hover",
    },
    { "gH", vim.lsp.buf.signature_help, "signature help" },
  }

  for _, value in ipairs(normal_keymaps) do
    vim.keymap.set("n", value[1], value[2], add_desc(value[3], attached_bufnr))
  end

  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, add_desc("signature help", attached_bufnr))

  local config = require("bdub.diagnostics").GetDiagnosticConfig("on")
  vim.diagnostic.config(config)
end

return M
