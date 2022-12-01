local M = {}

local function get_vim_path()
  local file_path = vim.fn.expand "%:."
  if file_path == "" then
    vim.cmd "echoerr 'No file path'"
  end

  return file_path
end

M.get_operator_file_path = function()
  local file_path = get_vim_path()

  if string.find(file_path, "commons/ui") then
    file_path = file_path:gsub("^(commons/)ui/(.*).tsx?$", "@neo/%1%2")
    vim.fn.setreg("+", file_path)
    print(file_path)
  elseif string.find(file_path, "ui/operator/src") then
    file_path = file_path:gsub("^ui(.*).tsx?$", "@neo%1")
    vim.fn.setreg("+", file_path)
    print(file_path)
  else
    vim.fn.setreg("+", file_path)
    print(file_path)
  end
end

M.get_file_path = function()
  local file_path = get_vim_path()

  vim.fn.setreg("+", file_path)
  vim.cmd "echo 'Copied file path to clipboard'"
end

return M
