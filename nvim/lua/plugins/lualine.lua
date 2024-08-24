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

    local anchor_icon = vim.fn.nr2char(0xf13d)

    lualine.setup({
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = "",
        disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
        globalstatus = true,
      },
      tabline = {},
      sections = {
        lualine_a = {
          get_branch,
        },
        lualine_b = {
          {
            "mode",
            fmt = function(mode)
              return "-- " .. mode .. " --"
            end,
            -- color = function()
            --   local bg = colors.bg1
            --   local fg = colors.gray2
            --   if vim.bo.modified then
            --     bg = colors.red
            --     fg = "#ffffff"
            --   end
            --
            --   return {
            --     fg = fg,
            --     bg = bg,
            --   }
            -- end,
          },
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
          -- "buffers",
        },
        lualine_c = {},
        lualine_z = {
          function()
            local current_line = vim.fn.line(".")
            local total_lines = vim.fn.line("$")
            local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
            local line_ratio = current_line / total_lines
            local index = math.ceil(line_ratio * #chars)
            return chars[index]
          end,
          "tabs",
        },
      },
      extensions = {},
    })
  end,
}
