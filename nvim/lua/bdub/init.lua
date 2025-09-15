require("bdub.options")
require("bdub.diagnostics")
require("bdub.remap")
require("bdub.inactive_backgrounds")
require("bdub.color_config")
require("bdub.autocommands")
require("bdub.buf-only")

-- local augroup = vim.api.nvim_create_augroup
-- local bdubsGroup = augroup("bdub", {})

-- local autocmd = vim.api.nvim_create_autocmd
-- local yank_group = augroup("HighlightYank", {})

function R(name)
  require("plenary.reload").reload_module(name)
end

-- remove trailing whitespaces
-- autocmd({ "BufWritePre" }, {
--   group = bdubsGroup,
--   pattern = "*",
--   command = [[%s/\s\+$//e]],
-- })

-- local function open_errors_in_cursor()
--   local files = {}
--
--   -- Get files from quickfix list
--   for _, item in ipairs(vim.fn.getqflist()) do
--     if item.filename then
--       table.insert(files, item.filename)
--     end
--   end
--
--   -- If no quickfix items, check quickfix buffer directly
--   if #files == 0 then
--     for _, win in ipairs(vim.api.nvim_list_wins()) do
--       local buf = vim.api.nvim_win_get_buf(win)
--       if vim.api.nvim_buf_get_option(buf, "buftype") == "quickfix" then
--         for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
--           local filename = line:match("^([^|]+)|")
--           if filename then
--             table.insert(files, filename)
--           end
--         end
--         break
--       end
--     end
--   end
--
--   if #files > 0 then
--     local cmd = "cursor " .. table.concat(files, " ")
--     -- print("Opening " .. #files .. " TypeScript error file" .. (#files > 1 and "s" or "") .. " in Cursor...")
--     vim.fn.jobstart(cmd, { detach = true })
--   else
--     print("No TypeScript errors found")
--   end
-- end
--
-- local function create_tsc_with_cursor_command()
--   vim.api.nvim_create_user_command("CursorQF", function()
--     open_errors_in_cursor()
--   end, {
--     desc = "Run TypeScript compiler and open errors in Cursor",
--   })
-- end
--
-- create_tsc_with_cursor_command()

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.g.copilot_no_tab_map = true
