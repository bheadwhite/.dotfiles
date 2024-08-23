local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local PlenaryPath = require("plenary.path")

-- Define a table representing a bookmark
---@class Bookmark
---@field annotation string: The name of the bookmark
---@field content string: The file path of the bookmark
---@field line_nr number: The line number in the file
---@field sign_idx number: The index of the sign
---@field file string: absolute file path of the bookmark

local show_global = true
local M = {}

function M.toggle_global()
  show_global = not show_global
end

---@return string: the root of the git repository
local function getGitRoot()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    return ""
  end
  return git_root
end

---@param file string: the file path
---@param line_nr number: the line number
---@return Bookmark: the new bookmark
local function getBookmarkFromLine(file, line_nr)
  local mark = vim.fn["bm#get_bookmark_by_line"](file, line_nr)
  mark.file = file
  return mark
end

local filter_by_current_file = true

---@return Bookmark[]: all bookmarks
function M.get_all_bookmarks()
  local files = vim.fn.sort(vim.fn["bm#all_files"]())
  local bookmarks = {} -- {content, file, line_nr, column_nr}[]

  for _, file in ipairs(files) do
    local line_nrs = vim.fn.sort(vim.fn["bm#all_lines"](file), "bm#compare_lines")
    for _, line_nr in ipairs(line_nrs) do
      table.insert(bookmarks, getBookmarkFromLine(file, line_nr))
    end
  end

  table.sort(bookmarks, function(a, b)
    return a.file > b.file
  end)

  return bookmarks
end

function M.get_project_bookmarks()
  local gitRoot = getGitRoot() or ""
  local bookmarks = M.get_all_bookmarks()

  local projectBookmarks = {}

  for _, bookmark in ipairs(bookmarks) do
    if string.find(bookmark.file, gitRoot) then
      table.insert(projectBookmarks, bookmark)
    end
  end

  return projectBookmarks
end

function M.get_current_file_bookmarks()
  local currentFile = vim.fn.expand("%:p")
  local bookmarks = M.get_all_bookmarks()

  local currentFileBookmarks = {}

  for _, bookmark in ipairs(bookmarks) do
    if bookmark.file == currentFile then
      table.insert(currentFileBookmarks, bookmark)
    end
  end

  return currentFileBookmarks
end

---bookmark display
---@param mark Bookmark: the bookmark
local function displayBookmark(mark)
  local rPath = PlenaryPath:new(mark.file):make_relative()
  local display = ""

  if mark["annotation"] ~= "" then
    display = mark["annotation"]
  else
    display = mark["content"]
  end
  -- Define the desired length for content
  local stringPadding = 40

  -- Calculate the number of spaces needed to pad content
  local padding_length = stringPadding - #display

  -- Ensure padding_length is not negative
  if padding_length < 0 then
    padding_length = 0
  end

  -- Pad content with spaces
  display = display .. string.rep(" ", padding_length)
  -- Append the arrow and rPath
  display = display .. "    -->     " .. rPath

  return display
end

---bookmark entry maker
---@param mark Bookmark: the bookmark
local make_entry = function(mark)
  local filename = mark.file
  local lnum = mark.line_nr

  local entry = {
    value = mark,
    ordinal = filename,
    display = displayBookmark(mark),
    filename = filename,
    lnum = lnum,
  }

  return entry
end

---@param opts table: telescope options
function M.telescope_bookmarks(opts)
  opts = opts or {}
  local bookmarks

  if filter_by_current_file then
    bookmarks = M.get_current_file_bookmarks()
  else
    bookmarks = M.get_project_bookmarks()
  end

  local title = "Bookmarks"
  if filter_by_current_file then
    title = title .. " (current file)"
  else
    title = title .. " (project)"
  end

  local function custom_mappings(prompt_bufnr, map)
    local actions = require("telescope.actions")

    -- Toggle filter and reload picker
    map("n", "m", function()
      actions.close(prompt_bufnr)
      filter_by_current_file = not filter_by_current_file
      M.telescope_bookmarks(opts)
    end)

    return true
  end

  pickers
    .new({}, {
      prompt_title = title,
      initial_mode = "normal",
      finder = finders.new_table({
        results = bookmarks,
        entry_maker = make_entry,
      }),
      sorter = conf.file_sorter({}),
      previewer = conf.grep_previewer({}),
      attach_mappings = custom_mappings,
    })
    :find()
end

return M
