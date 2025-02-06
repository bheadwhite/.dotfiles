vim.cmd([[
  "augroup _general_settings
  "  autocmd!
  "  autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR>
  "  autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200})
  "  autocmd BufWinEnter * :set formatoptions-=cro
  "  autocmd FileType qf set nobuflisted
  "augroup end

  augroup _git
    autocmd!
    autocmd FileType gitcommit setlocal wrap
    autocmd FileType gitcommit setlocal spell
  augroup end

  augroup _markdown
    autocmd!
    autocmd FileType markdown setlocal wrap
    autocmd FileType markdown setlocal spell
  augroup end

  augroup _auto_resize
    autocmd!
    autocmd VimResized * tabdo wincmd =
  augroup end

   "on pre buf save, remove trailing whitespace"
  augroup _remove_trailing_whitespace
    autocmd!
    autocmd BufWritePre * :%s/\s\+$//e
  augroup end

  augroup _help
    autocmd!
    autocmd FileType help wincmd L
  augroup end


  augroup refresh_lsp_progress
    autocmd!
    autocmd User LspProgressUpdate redrawstatus
  augroup END

  "augroup strdr4605
  "  autocmd FileType typescript,typescriptreact set makeprg=./node_modules/.bin/tsc\ \\\|\ sed\ 's/(\\(.*\\),\\(.*\\)):/:\\1:\\2:/'
  "augroup END

  " augroup _typescript_mkprg
  "   autocmd!
  "   autocmd FileType typescript,typescriptreact compiler tsc | setlocal makeprg=NODE_OPTIONS='--max-old-space-size=8192'\ npx\ tsc
  " augroup END

  " augroup set_vim_title
  "   autocmd!
  "   autocmd BufEnter * silent!lua require("bdub.commands").set_vim_title()
  " augroup END

]])

-- v2
vim.api.nvim_create_user_command("Govet", function()
  require("notify").notify("Running go vet", "info", { title = "Go Vet" })
  vim.fn.jobstart("go vet ./... 2>&1", {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, output, _)
      local qf_items = {}

      for _, line in ipairs(output) do
        -- Skip header lines (starting with "#")
        if not line:match("^%s*#") then
          -- Try to match a pattern like:
          -- campaigns/repository/campaign_module_attachment_links.go:44:23: <error message>
          local filename, lnum, col, msg = line:match("^%s*([^:]+%.go):(%d+):(%d+):%s*(.*)$")
          if filename and lnum and col and msg and msg ~= "" then
            -- Optionally trim any extra whitespace from the filename
            local trimmed_filename = filename:gsub("^%s+", "")
            table.insert(qf_items, {
              filename = trimmed_filename,
              lnum = tonumber(lnum),
              col = tonumber(col),
              text = msg,
            })
          end
        end
      end

      if vim.tbl_isempty(qf_items) then
        require("notify").notify("No issues found", "info", { title = "Go Vet" })
      else
        vim.fn.setqflist(qf_items, "r")
        vim.cmd("copen")
      end
    end,
  })
end, {})

--
local function get_test_position(full_name, package, package_name)
  -- Convert Go package path to a local directory
  local package_dir = package:gsub("%.", "/"):gsub(package_name .. "/", "")
  -- Find `_test.go` files in the package directory
  local test_files = vim.fn.systemlist("find " .. package_dir .. " -name '*_test.go'")
  local suite_name, test_name = full_name:match("^(.+)/([^/]+)$")

  if not suite_name then
    return nil, nil
  end

  local modified_name = test_name:gsub("_", " ")
  vim.print(modified_name)

  for _, file in ipairs(test_files) do
    -- Search for `func TestXYZ` inside each test file
    local grep_cmd = string.format("rg -n '%s' %s", modified_name, file)
    local grep_output = vim.fn.systemlist(grep_cmd)
    if #grep_output > 0 then
      local lnum = grep_output[1]:match("^(%d+):")
      if file and lnum then
        return file, tonumber(lnum)
      end
    end
  end

  return nil, nil
end

local function get_package_name()
  local output = vim.fn.systemlist("go list -json")
  for _, line in ipairs(output) do
    local package = line:match('"ImportPath"%s*:%s*"([^"]+)"')
    if package then
      return package
    end
  end
  return nil
end

local function run_go_test()
  local package_name = get_package_name()
  if not package_name then
    require("notify").notify("Failed to get package name", "error", { title = "Go Test" })
    return
  end
  local qf_items = {}

  vim.fn.jobstart("go test -json ./...", {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data, _)
      for _, line in ipairs(data) do
        local test_name = line:match('"Test":"([%w_/]+)"')
        local package = line:match('"Package":"([^"]+)"')
        local action = line:match('"Action":"(%w+)"')

        if test_name and package and action == "fail" then
          local filename, lnum = get_test_position(test_name, package, package_name)

          if filename and lnum then
            table.insert(qf_items, {
              filename = filename,
              lnum = lnum,
              col = 1,
              text = "Test failed: " .. test_name,
            })
          end
        end
      end
    end,
    on_exit = function()
      if vim.tbl_isempty(qf_items) then
        require("notify").notify("Go test: All tests passed", "info", { title = "Go Test" })
      else
        vim.fn.setqflist(qf_items, "r")
        vim.cmd("copen")
      end
    end,
  })
end

-- Create a Neovim command to trigger it
vim.api.nvim_create_user_command("Gotest", run_go_test, {})
