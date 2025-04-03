local catp_colors = require("bdub.catppuccin_colors")
return {
  "b0o/incline.nvim",
  config = function()
    require("incline").setup({
      window = {
        winhighlight = {
          active = { Normal = "InclineActive" },
          inactive = { Normal = "InclineInactive" },
        },
        padding = {
          left = 2,
          right = 2,
        },
        placement = {
          horizontal = "right",
          vertical = "bottom",
        },
        margin = {
          vertical = 1,
        },
      },
      hide = {
        cursorline = true,
      },
      render = function(props)
        local buf_name = vim.api.nvim_buf_get_name(props.buf)
        local isOil = string.match(buf_name, "oil")

        if isOil then
          return { require("bdub.cwd").get_cwd_path_display(props.buf) }
        end

        local filename = vim.fn.fnamemodify(buf_name, ":t")
        if filename == "" then
          filename = "[No Name]"
        end

        local function get_git_diff()
          local icons = { removed = "", changed = "", added = "" }
          local signs = vim.b[props.buf].gitsigns_status_dict
          local labels = {}
          if signs == nil then
            return labels
          end
          for name, icon in pairs(icons) do
            if tonumber(signs[name]) and signs[name] > 0 then
              if #labels == 0 then
                table.insert(labels, { "  " })
              end

              table.insert(labels, { icon .. " " .. signs[name] .. " ", group = "Diff" .. name })
            end
          end

          return labels
        end

        local function get_diagnostic_label()
          local icons = { error = "", warn = "", info = "", hint = "" }
          local label = {}

          for severity, icon in pairs(icons) do
            local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
            if n > 0 then
              if #label == 0 then
                table.insert(label, { "┊  " })
              end

              table.insert(label, { icon .. " " .. n .. " ", group = "DiagnosticSign" .. severity })
            end
          end

          return label
        end

        local isModified = vim.bo[props.buf].modified
        local filenameDisp = filename

        local isDuplicate = require("bdub.win_utils").is_win_duplicate(props.win)

        if isDuplicate then
          filenameDisp = "  " .. filenameDisp
        end

        return {
          {
            isModified and " 🌱 " or "",
          },
          {
            "  " .. filenameDisp .. "  ",
            gui = isModified and "bold,italic" or "bold",
            guifg = "#000000",
            guibg = isModified and catp_colors.mocha.green
              or props.focused and catp_colors.mocha.peach
              or isDuplicate and catp_colors.mocha.blue
              or "#ffffff",
          },
          -- { get_git_diff() },
          -- { get_diagnostic_label() },
        }
      end,
    })
  end,
  -- Optional: Lazy load Incline
  event = "VeryLazy",
}
