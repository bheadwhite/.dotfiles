local color_config = require("bdub.color_config")

return {
  "nvim-lualine/lualine.nvim",
  cond = not vim.g.vscode,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local colors = require("bdub.catppuccin_colors")
    local lualine = require("lualine")

    local function is_zoomed()
      local current_tab = vim.api.nvim_get_current_tabpage()
      local success, zoomwintab = pcall(vim.api.nvim_tabpage_get_var, current_tab, "zoomwintab")
      if success then
        return zoomwintab
      else
        return false
      end
    end

    lualine.setup({
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = "",
        disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
        globalstatus = true,
      },
      tabline = {
        lualine_a = {
          function()
            local cwd = vim.fn.getcwd()
            local home = os.getenv("HOME")
            if cwd:sub(1, #home) == home then
              cwd = "~" .. cwd:sub(#home + 1)
            end
            return cwd
          end,
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      sections = {
        lualine_a = {
          {},
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {
          {
            "tabs",
            tabs_color = {
              active = { bg = color_config.activeTabBg, fg = color_config.activeTabFg },
            },
            mode = 2,
            cond = function()
              return vim.fn.tabpagenr("$") > 1
            end,
          },
        },
        lualine_z = {
          {
            function()
              if is_zoomed() then
                return "ZOOOM"
              end
              return ""
            end,
            color = { bg = color_config.zoomBg },
          },
        },
      },
      extensions = {},
    })

    vim.cmd([[hi lualine_a_insert guibg=]] .. colors.macchiato.mantle)
    vim.cmd([[hi lualine_a_normal guibg=]] .. colors.macchiato.mantle)
    vim.cmd([[hi lualine_a_visual guibg=]] .. colors.macchiato.mantle)
    vim.cmd([[hi lualine_a_command guibg=]] .. colors.macchiato.mantle)
    vim.cmd([[hi lualine_c_normal guibg=]] .. colors.macchiato.mantle)
    vim.cmd([[hi lualine_c_inactive guibg=]] .. colors.macchiato.mantle)
  end,
}
