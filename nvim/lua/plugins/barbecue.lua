return {
  "utilyre/barbecue.nvim", -- uses navic - vscode like bookmarks in the winbar
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local function custom_section(bufnr, winnr)
      local Path = require("plenary.path")
      local buf_width = vim.api.nvim_buf_get_option(bufnr, "textwidth")
      if buf_width == 0 then
        buf_width = vim.api.nvim_win_get_width(winnr)
      end

      local file_path = vim.api.nvim_buf_get_name(bufnr)
      local parent_dir = Path:new(file_path):parent():absolute()
      local cwd = vim.fn.getcwd()

      local relative_path = Path:new(parent_dir):make_relative(cwd)

      local max_length = math.floor(buf_width * 0.5) -- 50% of the buffer width

      if #relative_path > max_length then
        return Path:new(relative_path):shorten() .. "/"
      end

      return relative_path .. "/"
    end

    local barbecue = require("barbecue")
    barbecue.setup({
      show_navic = false,
      show_modified = true,
      show_dirname = false,
      theme = {
        basename = {
          fg = "#ffffff",
          bold = true,
        },
      },
      custom_section = custom_section,
    })
  end,
}
