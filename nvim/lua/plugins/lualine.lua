local color_config = require("bdub.color_config")

return {
  "nvim-lualine/lualine.nvim", -- statusline
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local colors = require("bdub.catppuccin_colors")
    local lualine = require("lualine")

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 80
    end

    local full_path_minus_filename = function()
      return vim.fn.expand("%:.:h") .. "/"
    end

    local function get_branch()
      require("lualine.components.branch.git_branch").init()
      local branch = require("lualine.components.branch.git_branch").get_branch()
      return string.sub(branch, 1, 40)
    end

    local function is_zoomed()
      local current_tab = vim.api.nvim_get_current_tabpage()
      local success, zoomwintab = pcall(vim.api.nvim_tabpage_get_var, current_tab, "zoomwintab")
      if success then
        return zoomwintab
      else
        return false
      end
    end

    local anchor_icon = vim.fn.nr2char(0xf13d)

    local dap = require("dap")

    local dap_status = function()
      -- Check if a debugging session is active
      if dap.session() ~= nil then
        return " DAP Active" -- Icon + message when DAP is running
      else
        return "" -- Empty when DAP is not active
      end
    end

    local function get_tabbar_widths()
      local total_width = vim.o.columns
      local left_width = math.floor(total_width * 0.30)
      local right_width = math.floor(total_width * 0.30)
      local center_width = total_width - left_width - right_width -- Remaining width

      return {
        left = left_width,
        center = center_width,
        right = right_width,
      }
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
            --display the current working directory
            --from the home directory
            --ie ~/Projects/tcn
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
          -- {
          --   "aerial",
          --   depth = 3,
          --   colored = true,
          --   color = { bg = colors.mocha.crust, fg = colors.mocha.rosewater },
          -- },
          -- {
          -- full_path_minus_filename,
          -- color = function()
          --   -- local winid = vim.fn.win_getid()
          --   -- local isDup = win_utils.isWindowDuplicate(winid)
          --   --
          --   -- if isDup then
          --   --   return { bg = colors.orange, fg = colors.fg }
          --   -- end
          --
          --   return { bg = color_config.sectionFilePathBg, fg = color_config.sectionFilePathFg }
          -- end,
          -- },
        },
        lualine_b = {
          -- {
          --   "mode",
          --   fmt = function(mode)
          --     return "-- " .. mode .. " --"
          --   end,
          --   -- color = function()
          --   --   local bg = colors.bg1
          --   --   local fg = colors.gray2
          --   --   if vim.bo.modified then
          --   --     bg = colors.red
          --   --     fg = "#ffffff"
          --   --   end
          --   --
          --   --   return {
          --   --     fg = fg,
          --   --     bg = bg,
          --   --   }
          --   -- end,
          -- },
        },
        lualine_c = {},
        lualine_x = {
          {
            "tabs",
            tabs_color = {
              -- Same values as the general color option can be used here.
              active = { bg = color_config.activeTabBg, fg = color_config.activeTabFg },
            },
            mode = 2,
            cond = function()
              -- if only one buffer is open, don't show tabs
              return vim.fn.tabpagenr("$") > 1
            end,
          },
          -- function()
          --   local current_line = vim.fn.line(".")
          --   local total_lines = vim.fn.line("$")
          --   local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
          --   local line_ratio = current_line / total_lines
          --   local index = math.ceil(line_ratio * #chars)
          --   return chars[index]
          -- end,
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
