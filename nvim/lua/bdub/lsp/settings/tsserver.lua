local M = {}

local ts_options = {
  preferences = {
    importModuleSpecifierPreference = "non-relative",
  },
  maxTsServerMemory = 4096,
}

M.init_options = ts_options

-- M.init_options = vim.tbl_deep_extend("force", ts_utils.init_options, ts_options)
-- M.root_dir = function()
--   return vim.loop.cwd()
-- end

return M
