local M = {}

function getCwdDirectory()
  local cwd = vim.fn.getcwd()

  local dir_parts = vim.fn.split(cwd, "/")
  return dir_parts[#dir_parts]
end

function getPPathDir(path)
  if path:is_file() then
    return path:parent()
  else
    return path
  end
end

-- planery relative path
function relativeDirToCwd(path)
  local cwd = vim.fn.getcwd()
  local is_in_cwd = string.sub(path, 1, #cwd) == cwd
  if not is_in_cwd then
    return path
  end

  local pPathDir = getPPathDir(require("plenary.path"):new(path))
  local cwd_name = getCwdDirectory() or ""
  local relative = pPathDir:make_relative(cwd)

  if relative == "." then
    return cwd_name
  end

  -- if relative starts with a slash, it's an absolute path
  if string.sub(relative, 1, 1) == "/" then
    return relative
  end

  return string.gsub(cwd_name .. "/" .. relative, "/", " → ")
end

function M.get_cwd_path_display(buf)
  bufname = vim.api.nvim_buf_get_name(buf or 0)
  local isOil = string.match(bufname, "oil")

  if isOil then
    bufname = bufname:gsub("oil://", "")
  end

  return relativeDirToCwd(bufname)
end

return M
