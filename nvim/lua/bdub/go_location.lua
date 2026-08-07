-- Classify a Go buffer by *where its file lives*, so windows showing external Go
-- code (a dependency in the module cache, or the stdlib) can be tinted differently
-- from your own project code. Makes a `gd` jump out of your project obvious.
--
-- Detection uses `go env GOMODCACHE` / `GOROOT`, resolved once and cached. The
-- resolve is a single synchronous call the first time a Go buffer is classified
-- (not per event), so it never turns into a redraw hazard the way a per-WinEnter
-- shell call would.
local M = {}

-- nil until resolved; afterwards a table (possibly empty on failure) so we never
-- re-run `go env`.
local roots = nil

local function resolve_roots()
  if roots ~= nil then
    return roots
  end
  roots = {}
  if vim.fn.executable("go") ~= 1 then
    return roots
  end
  -- One cheap call, both values at once, cached forever.
  local out = vim.fn.system({ "go", "env", "GOMODCACHE", "GOROOT" })
  if vim.v.shell_error ~= 0 then
    return roots
  end
  local lines = vim.split(vim.trim(out), "\n", { trimempty = true })
  if lines[1] and lines[1] ~= "" then
    roots.modcache = vim.fs.normalize(lines[1])
  end
  if lines[2] and lines[2] ~= "" then
    -- stdlib sources live under GOROOT/src.
    roots.goroot_src = vim.fs.normalize(lines[2]) .. "/src"
  end
  return roots
end

-- True when `path` is `dir` itself or sits inside it (both normalized absolutes).
local function under(path, dir)
  if not dir or dir == "" then
    return false
  end
  return path == dir or path:sub(1, #dir + 1) == dir .. "/"
end

-- "project" | "mod" | "stdlib" for a Go source buffer, or nil for anything that
-- isn't a named *.go file (those are left to the normal background logic).
function M.classify(bufnr)
  bufnr = bufnr or 0
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" or not name:match("%.go$") then
    return nil
  end
  local path = vim.fs.normalize(name)
  local r = resolve_roots()
  if under(path, r.modcache) then
    return "mod"
  end
  if under(path, r.goroot_src) then
    return "stdlib"
  end
  return "project"
end

-- winhighlight Normal-target group for an external Go buffer, or nil when the
-- normal (project / focus-based) background should apply. 2-way: any out-of-project
-- Go (module cache OR stdlib) shares one tint. classify() still distinguishes them
-- if you ever want to split the colors again.
function M.bg_group(bufnr)
  local kind = M.classify(bufnr)
  if kind == "mod" or kind == "stdlib" then
    return "GoExternalBg"
  end
  return nil
end

return M
