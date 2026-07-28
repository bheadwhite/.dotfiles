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

-- Run api-linter and set diagnostics. Async (vim.system) so nvim's UI never
-- blocks on the subprocess, and argv form (no shell) so stderr is captured off to
-- the side instead of leaking onto the screen. A blocking io.popen here used to
-- stall redraws on every window enter and corrupt the grid.
function M.run_linter(bufnr)
  -- Bail if api-linter isn't installed — nothing to run, nothing to leak.
  if vim.fn.executable("api-linter") ~= 1 then
    return
  end
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == "" then
    return
  end
  -- argv form: no shell, so expand ~ ourselves; stdout is JSON, stderr is ignored.
  vim.system({
    "api-linter",
    "-I",
    vim.fn.expand("~/code/googleapis"),
    "--output-format=json",
    filepath,
  }, { text = true }, function(obj)
    local out = obj.stdout
    if not out or out == "" then
      return
    end
    local diagnostics = parse_linter_output(out)
    -- vim.system's callback is off the main loop; API calls must be scheduled.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.diagnostic.set(namespace_id, bufnr, diagnostics, {})
      end
    end)
  end)
end

-- Lint on open and save only. WinEnter/BufEnter fired this on every focus change,
-- which is what turned a slow linter into a redraw hazard.
vim.api.nvim_create_autocmd({
  "BufReadPost",
  "BufWritePost",
}, {
  pattern = "*.proto",
  callback = function(args)
    M.run_linter(args.buf)
  end,
})

return M
