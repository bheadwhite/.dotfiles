local M = {}

local function tbl_to_file(table)
  local log_path = os.getenv "VIM_LOG"
  if not log_path then
    return
  end

  local file = assert(io.open(log_path, "w"))
  if file then
    file:write(vim.inspect(table))
    file:close()
  end
end

M.tbl_to_file = tbl_to_file

return M
