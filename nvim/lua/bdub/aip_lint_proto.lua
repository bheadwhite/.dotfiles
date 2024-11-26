local M = {}

local namespace_id = vim.api.nvim_create_namespace("api-linter")

-- Parse the JSON output from api-linter
local function parse_linter_output(output)
  local diagnostics = {}
  local ok, results = pcall(vim.json.decode, output)
  if not ok or not results then
    return diagnostics
  end

  -- Iterate over the list of files
  for _, file in ipairs(results) do
    -- Iterate over the problems reported for this file
    for _, problem in ipairs(file.problems or {}) do
      local start_pos = problem.location.start_position
      local end_pos = problem.location.end_position

      table.insert(diagnostics, {
        lnum = start_pos.line_number - 1,
        col = start_pos.column_number - 1,
        end_lnum = end_pos.line_number - 1,
        end_col = end_pos.column_number - 1,
        severity = vim.diagnostic.severity.ERROR,
        message = string.format("%s\nRule: %s\n%s", problem.message, problem.rule_id, problem.rule_doc_uri),
        source = "api-linter",
      })
    end
  end

  return diagnostics
end

-- Function to run the api-linter command and set diagnostics
function M.run_linter(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local cmd = string.format("api-linter -I ~/Projects/googleapis --output-format=json %s", filepath)
  local handle = io.popen(cmd)
  if not handle then
    return
  end

  local result = handle:read("*a")
  handle:close()

  if result and result ~= "" then
    local diagnostics = parse_linter_output(result)
    vim.diagnostic.set(namespace_id, bufnr, diagnostics, {})
  end
end

-- Function to run the api-linter command and set diagnostics

vim.api.nvim_create_autocmd({
  "BufEnter",
  "WinEnter",
  "BufWritePost",
}, {
  pattern = "*.proto",
  callback = function(args)
    M.run_linter(args.buf)
  end,
})

return M
