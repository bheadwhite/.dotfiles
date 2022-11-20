local M = {}

local function get_file_path()
  local file_path = vim.fn.expand "%:."
  if file_path == "" then
    vim.cmd "echoerr 'No file path'"
    return
  end

  if string.find(file_path, "commons/ui") then
    vim.fn.setreg("+", file_path:gsub("^(commons/)ui/(.*).tsx?$", "@neo/%1%2"))
    vim.cmd "echo 'Copied commons file path to clipboard'"
  elseif string.find(file_path, "ui/operator/src") then
    vim.fn.setreg("+", file_path:gsub("^ui(.*).tsx?$", "@neo%1"))
    vim.cmd "echo 'Copied operator file path to clipboard'"
  else
    vim.fn.setreg("+", file_path)
    vim.cmd "echo 'Copied file path to clipboard'"
  end
end

M.get_file_path = get_file_path

return M
