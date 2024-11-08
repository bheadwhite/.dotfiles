return {
  "nvim-lualine/lualine.nvim", -- statusline
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local colors = require("bdub.everforest_colors")
    local lualine = require("lualine")

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 80
    end

    -- local full_path_minus_filename = function()
    --   return vim.fn.expand("%:.:h") .. "/"
    -- end

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

    lualine.setup({
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = "",
        disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
        -- globalstatus = true,
      },
      tabline = {
        lualine_a = {
          {
            function()
              if is_zoomed() then
                return "ZOOOM"
              end

              return ""
            end,
            color = { bg = colors.red },
          },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {
          {
            "tabs",
            tabs_color = {
              -- Same values as the general color option can be used here.
              active = { bg = colors.blue, fg = "#ffffff" },
            },
            mode = 2,
            cond = function()
              -- if only one buffer is open, don't show tabs
              return vim.fn.tabpagenr("$") > 1
            end,
          },
        },

        lualine_y = {
          {
            function()
              local sesh = " "
              sesh = sesh .. require("auto-session.lib").current_session_name(true)
              return sesh
            end,
            color = { bg = colors.bg1, fg = "#FFFFFF" },
          },
          {
            function()
              local grapple = require("grapple")
              local app = grapple.app()
              if app == nil then
                return ""
              end
              local scope = app.scope_manager:get(app.settings.scope)
              return anchor_icon .. " " .. scope.name
            end,
            color = { fg = "#ffffff", bg = colors.bg1 },
          },
          {
            "diff",
            colored = true,
            symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
            cond = hide_in_width,
            color = { bg = colors.bg1 },
          },
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            sections = { "error", "warn" },
            symbols = { error = " ", warn = " " },
            colored = false,
            update_in_insert = false,
            always_visible = true,
            color = { bg = colors.bg1 },
          },
          {
            dap_status,
          },
          {
            function()
              local files = vim.fn.sort(vim.fn["bm#all_files"]())
              local matching_files = {}
              local current_file = vim.fn.expand("%:p")
              for _, file in ipairs(files) do
                if file == current_file then
                  local line_nrs = vim.fn.sort(vim.fn["bm#all_lines"](file), "bm#compare_lines")
                  for _, line_nr in ipairs(line_nrs) do
                    table.insert(matching_files, file)
                  end
                end
              end

              if #matching_files == 0 then
                return ""
              end

              return "🔖 " .. #matching_files
            end,
            color = { bg = colors.bg1 },
          },
        },
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = { { "filename", color = { bg = colors.bg2, fg = colors.fg } } },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      sections = {
        lualine_a = {
          {
            function()
              if is_zoomed() then
                return "ZOOOM"
              end
              return ""
            end,
            color = { bg = colors.red },
          },
          { "filename", color = { bg = colors.bg2, fg = colors.fg } },
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
          function()
            local current_line = vim.fn.line(".")
            local total_lines = vim.fn.line("$")
            local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
            local line_ratio = current_line / total_lines
            local index = math.ceil(line_ratio * #chars)
            return chars[index]
          end,
        },
        lualine_z = {
          {
            function()
              if is_zoomed() then
                return "ZOOOM"
              end
              return ""
            end,
            color = { bg = colors.red },
          },
        },
      },
      extensions = {},
    })
  end,
}
