local colors = require("bdub.everforest_colors")

local default_diagnostic_config = {
  underline = true,
  signs = true,
  update_in_insert = false,
  virtual_text = false,
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

return M
