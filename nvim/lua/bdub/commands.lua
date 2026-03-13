local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

local dropdown_theme = require("telescope.themes").get_dropdown({
  previewer = false,
  layout_config = {
    width = 800,
  },
})

local function get_vim_path()
  local file_path = vim.fn.expand("%:.")
  if file_path == "" then
    vim.cmd("echoerr 'No file path'")
  end

  return file_path
end

M.open_qf_in_cursor = function()
  local files = {}

  -- Get files from quickfix list
  for _, item in ipairs(vim.fn.getqflist()) do
    if item.filename then
      table.insert(files, item.filename)
    end
  end

  -- If no quickfix items, check quickfix buffer directly
  if #files == 0 then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_get_option(buf, "buftype") == "quickfix" then
        for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
          local filename = line:match("^([^|]+)|")
          if filename then
            table.insert(files, filename)
          end
        end
        break
      end
    end
  end

  if #files > 0 then
    -- vim.print("Found " .. #files .. " TypeScript error file" .. (#files > 1 and "s" or "") .. ":")
    local cmd = "cursor " .. table.concat(files, " ")
    -- print("Opening " .. #files .. " TypeScript error file" .. (#files > 1 and "s" or "") .. " in Cursor...")
    vim.fn.jobstart(cmd, { detach = true })
  else
    print("No TypeScript errors found")
  end
end

local function populate_quickfix_from_clipboard()
  -- Get the clipboard content
  local clipboard_content = vim.fn.getreg("+") -- '+' register is the system clipboard

  -- Split the clipboard content into lines
  local lines = vim.split(clipboard_content, "\n")

  -- Create an empty quickfix list
  local qflist = {}

  -- Process each line and extract the file path and line number
  for _, line in ipairs(lines) do
    if line ~= "" then
      -- Match the file path and line number, ignoring the last ':number' part
      local filepath, lineno, colno = string.match(line, "(.-):(%d+):?(%d*)$")
      if filepath and lineno then
        -- Check if the file path contains "src/" and slice off any prefixed characters
        local src_index = string.find(filepath, "src/")
        if src_index then
          filepath = string.sub(filepath, src_index)
        end
        table.insert(qflist, {
          filename = filepath,
          lnum = tonumber(lineno),
          col = tonumber(colno) or 1, -- Use column 1 if not specified
          text = "", -- Optionally, you could add an error message here
        })
      else
        -- If no colon is found, use the whole line as the file path with default line and column
        local src_index = string.find(line, "src/")
        if src_index then
          line = string.sub(line, src_index)
        end
        table.insert(qflist, {
          filename = line,
          lnum = 1,
          col = 1,
          text = "", -- Optionally, you could add an error message here
        })
      end
    end
  end

  -- Set the quickfix list and open it
  vim.fn.setqflist(qflist, "r")
  vim.cmd("copen")
end

vim.api.nvim_create_user_command("QFListFromClipboard", populate_quickfix_from_clipboard, {})

local function populate_deduplicated_quickfix(directory)
  -- Use fd to find all files recursively in the given directory
  local cmd = "fd --type f . " .. directory
  local files = vim.fn.systemlist(cmd)

  -- Populate the quickfix list
  local quickfix_list = {}
  for _, file in ipairs(files) do
    if vim.fn.filereadable(file) == 1 then
      table.insert(quickfix_list, { filename = file, lnum = 1, col = 1, text = "" })
    end
  end

  -- Set the quickfix list and open it
  vim.fn.setqflist(quickfix_list, "r")
  vim.cmd("copen")
end

-- Example usage: populate_deduplicated_quickfix with a specific directory
-- Replace '/path/to/directory' with your target directory
vim.api.nvim_create_user_command("QFListFilesUnderDir", function(opts)
  populate_deduplicated_quickfix(opts.args)
end, {
  nargs = 1,
})

M.set_vim_title = function()
  local cwd = vim.fn.getcwd()
  local dir_name = cwd:match("^.+/(.+)$")

  vim.cmd("set titlestring=" .. dir_name)
end

local function find_directories()
  return finders.new_oneshot_job({ "fd", "--type", "d" })
end

local function get_dir_results_from_picker(picker)
  local selected_entry = action_state.get_selected_entry()
  local selected = { selected_entry[1] }

  for _, entry in ipairs(picker:get_multi_selection()) do
    local text = entry.text
    if not text then
      if type(entry.value) == "table" then
        text = entry.value.text
      else
        text = entry.value
      end
    end

    table.insert(selected, text)
  end

  return selected
end

local function find_files_attach_mapping(prompt_bufnr)
  actions.select_default:replace(function()
    local picker = action_state.get_current_picker(prompt_bufnr)
    local dir_results = get_dir_results_from_picker(picker)

    actions.close(prompt_bufnr)

    require("telescope.builtin").find_files({
      prompt_title = "Find files in dirs",
      search_dirs = dir_results,
    })
  end)

  return true
end

local function grep_files_attach_mapping(prompt_bufnr)
  actions.select_default:replace(function()
    local picker = action_state.get_current_picker(prompt_bufnr)
    local dir_results = get_dir_results_from_picker(picker)

    actions.close(prompt_bufnr)

    require("telescope.builtin").live_grep({
      prompt_title = "live grep within dirs...",
      search_dirs = dir_results,
    })
  end)

  return true
end

M.copy_operator_file_path = function(file_path)
  if string.find(file_path, "commons/ui") then
    file_path = file_path:gsub("^(commons/)ui/(.*).tsx?$", "@neo/%1%2")
    vim.fn.setreg("+", file_path)
    print("copied " .. file_path)
  elseif string.find(file_path, "ui/operator/src") then
    file_path = file_path:gsub("^ui(.*).tsx?$", "@neo%1")
    vim.fn.setreg("+", file_path)
    print("copied " .. file_path)
  else
    vim.fn.setreg("+", file_path)
    print("copied " .. file_path)
  end
end

M.copy_file_path = function()
  local file_path = get_vim_path()
  M.copy_operator_file_path(file_path)
end

M.find_files_within_directories = function()
  local options = {
    prompt_title = "Select Directories For File Search",
    sorter = conf.generic_sorter(),
    finder = find_directories(),
    attach_mappings = find_files_attach_mapping,
  }

  pickers.new(dropdown_theme, options):find()
end

M.grep_string_within_directories = function()
  local options = {
    prompt_title = "Select Dirs to Search",
    sorter = conf.generic_sorter(),
    finder = find_directories(),
    attach_mappings = grep_files_attach_mapping,
  }

  pickers.new(dropdown_theme, options):find()
end

M.format_jq = function()
  vim.cmd("%!jq .")
end

M.list_buffers = function()
  local function run_picker()
    pickers
      .new({
        initial_mode = "normal",
      }, {
        prompt_title = "Buffers",
        finder = finders.new_table({
          results = vim.fn.getbufinfo({
            buflisted = 1,
          }),
          entry_maker = function(entry)
            return {
              value = entry.bufnr,
              display = entry.name,
              ordinal = entry.bufnr .. " : " .. entry.name,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          local make_current_buffer = function()
            local selection = action_state.get_selected_entry()
            if selection then
              actions.close(prompt_bufnr)
              vim.cmd("buffer " .. selection.value)
            end
          end
          local delete_buffer = function()
            local selection = action_state.get_selected_entry()
            if selection then
              vim.api.nvim_buf_delete(selection.value, {
                force = true,
              })
              run_picker()
            end
          end

          map("i", "<CR>", make_current_buffer)
          map("n", "<CR>", make_current_buffer)
          map("n", "q", delete_buffer)
          return true
        end,
      })
      :find()
  end

  run_picker()
end

vim.api.nvim_create_user_command("ApplyLastSubstitute", function()
  -- Get the last substitute command from the command history
  local last_cmd = vim.fn.histget(":", -2)
  print("last sub: " .. last_cmd)

  -- Extract the substitute command if it exists
  local substitute_cmd = last_cmd:match("^%%?s/.*$")

  if not substitute_cmd then
    print("No substitute command found in history.")
    return
  end

  local cdo_cmd = "silent! noau cdo " .. substitute_cmd .. " | update"

  -- Iterate over the quickfix list and apply the substitute command
  vim.cmd(cdo_cmd)

  print("Applied substitute command to all quickfix list items.")
end, {})

function _G.printK(obj)
  if obj == nil then
    print("nil")
    return
  end

  if type(obj) == "function" then
    print("function")
    return
  end

  if type(obj) ~= "table" then
    print(obj)
    return
  end

  local keys = {}
  for key, value in pairs(obj) do
    table.insert(keys, {
      key = key,
      value_type = type(value),
    })
  end

  table.sort(keys, function(a, b)
    if a.value_type == b.value_type then
      return a.key < b.key
    else
      return a.value_type > b.value_type
    end
  end)

  print("Keys and their value types of the object:")
  for _, item in ipairs(keys) do
    print(item.key .. " (" .. item.value_type .. ")")
  end
end

return M
