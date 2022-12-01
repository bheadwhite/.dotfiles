local ts_utils = require "nvim-lsp-ts-utils"

local M = {}

local ts_options = {
  preferences = {
    importModuleSpecifierPreference = "non-relative",
  },
}

M.init_options = vim.tbl_deep_extend("force", ts_utils.init_options, ts_options)

return M
