local colors = require("bdub.everforest_colors")

local default_diagnostic_config = {
  underline = true,
  signs = true,
  update_in_insert = false,
  virtual_text = false,
  virtual_lines = {
    only_current_line = true,
    highlight_whole_line = false,
  },
  severity_sort = true,
}

local diagnostics_toggle_config = {
  on = {
    underline = true,
  },
  off = {
    underline = {
      -- only show errors underlined when in off mode
      severity = {
        vim.diagnostic.severity.ERROR,
      },
    },
  },
}

local M = {}

-- local original_publish_diagnostics_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
-- function M.overridePublishDiagnosticsHandler()
-- 	vim.lsp.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
-- 		-- Modify the diagnostics data
-- 		if result and result.diagnostics then
-- 			vim.print(result.diagnostics[1])
-- 			for _, d in ipairs(result.diagnostics) do
-- 				-- if range of col is 0, then it's a line diagnostic
-- 				if d.range.start.character == 0 then
-- 					d.range["end"].character = 1
-- 				end
-- 			end
-- 		end
--
-- 		-- Call the original handler to proceed with displaying diagnostics
-- 		original_publish_diagnostics_handler(_, result, ctx, config)
-- 	end
-- end

-- not sure why i need this yet... had something to do with the python workflow...
function M.setDiagnosticColorOverrides()
  vim.cmd([[
    highlight DiagnosticHint guifg=#a9a1e1 gui=underline
    highlight DiagnosticInfo guifg=#c0c0c0 gui=underline
    highlight DiagnosticLineHint guifg=#a9a1e1 gui=underline
  ]])
  vim.cmd("highlight DiagnosticUnnecessary guifg=" .. colors.fg .. " gui=undercurl,bold")
end

function M.GetDiagnosticConfig(on_or_off)
  if on_or_off == "on" then
    return vim.tbl_deep_extend("force", default_diagnostic_config, diagnostics_toggle_config.on)
  else
    return vim.tbl_deep_extend("force", default_diagnostic_config, diagnostics_toggle_config.off)
  end
end

vim.diagnostic.config(M.GetDiagnosticConfig("on"))

vim.fn.sign_define("DiagnosticSignError", { text = "💀", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

-- -- show diagnostics on cursor hold if no floating window is open
-- vim.api.nvim_create_autocmd({ "CursorHold" }, {
--   pattern = "*",
--   callback = function()
--     local cursor_pos = vim.api.nvim_win_get_cursor(0)
--     local cursor_row = cursor_pos[1] - 1 -- Convert to 0-based index
--
--     for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
--       local config = vim.api.nvim_win_get_config(winid)
--       if config.zindex then
--         local win_row = config.row
--         local win_height = config.height
--
--         if cursor_row >= win_row and cursor_row < (win_row + win_height) then
--           -- Cursor is within the window's range, do not open float
--           return
--         end
--       end
--     end
--
--     -- No overlapping window found, open the diagnostic float
--     vim.diagnostic.open_float({
--       scope = "cursor",
--       focusable = false,
--       close_events = {
--         "CursorMoved",
--         "CursorMovedI",
--         "BufHidden",
--         "InsertCharPre",
--         "WinLeave",
--       },
--     })
--   end,
-- })

return M
