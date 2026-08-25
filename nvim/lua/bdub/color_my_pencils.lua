local catp_colors = require("bdub.catppuccin_colors")
local shadow = {
  bg = "#1D2326",
  bg_dark = "#182924",
  bg_bright = "#252A2E",
  bg_green = "#1A2A1A",
  bg_green_dark = "#28402C",
  bg_red_dark = "#43292D",
  bg_blue = "#1A2A2F",
  bg_blue_bright = "#28343D",
  bg_blue_text = "#3D5A6E",
  fg = "#E6E7E6",
  fg_dark = "#A0A1A0",
  black = "#242B2D",
  black_bright = "#485457",
  red = "#BC8F7D",
  red_bright = "#D4A394",
  green = "#96B088",
  green_bright = "#ABC49E",
  yellow = "#CCAC7D",
  yellow_bright = "#E2BF8F",
  blue = "#7E9AAB",
  blue_bright = "#94B1C4",
  magenta = "#A68CAA",
  magenta_bright = "#BC9EC0",
  cyan = "#839C98",
  cyan_bright = "#97B3AF",
  white = "#CED3DC",
  white_bright = "#E8EBF0",
}

local colors = {
  muted_teal = "#2A3D40",
  dark_olive = "#2C322E",
  deep_blue = "#28343D",
  soft_purple = "#322E40",
  subtle_gray = "#252A2E",
  darkest_black = "#000000",
  darker_black = "#161D21",
  bg = "#1D2326",
  fg = "#E6E7E6",
  dark = "#182924",
  black = "#242B2D",
  black_bright = "#485457",
  red = "#BC8F7D",
  red_bright = "#D4A394",
  red_dark = "#4E362C",
  green = "#96B088",
  green_bright = "#ABC49E",
  green_dark = "#374833",
  yellow = "#CCAC7D",
  yellow_bright = "#E2BF8F",
  blue = "#7E9AAB",
  blue_bright = "#94B1C4",
  magenta = "#A68CAA",
  magenta_bright = "#BC9EC0",
  cyan = "#839C98",
  cyan_bright = "#97B3AF",
  white = "#CED3DC",
  white_bright = "#E8EBF0",
}

function colorMyPencils()
  vim.cmd([[highlight WinSeparator guifg=]] .. colors.bg)
  vim.cmd([[highlight CursorLine guibg=]] .. colors.deep_blue)
  vim.cmd([[highlight QuickFixLine guibg=]] .. colors.dark)
  vim.cmd([[highlight Visual guibg=]] .. colors.white .. [[ guifg=]] .. colors.black)
  vim.cmd([[highlight MyInactiveBufferColor guibg=]] .. colors.black)
  -- Out-of-project Go buffers (module cache OR stdlib) share one tint, applied by
  -- win_utils.set_window_backgrounds via bdub.go_location. A dark desaturated wine-red
  -- shift of the base bg (#1D2326) — "you're in read-only code that isn't yours."
  vim.cmd([[highlight GoExternalBg guibg=#2E1F24]])
  vim.cmd([[highlight Winbar guibg=]] .. colors.bg .. [[ guifg=]] .. colors.white_bright)
  vim.cmd([[highlight WinbarNC guibg=]] .. colors.black .. [[ guifg=]] .. colors.white_bright)
  vim.cmd([[highlight DropbarHover guibg=]] .. colors.bg .. [[ guifg=]] .. colors.white_bright)
  vim.cmd([[highlight DropbarCurrentContext guibg=]] .. colors.bg .. [[ guifg=]] .. colors.white_bright)
  vim.cmd([[highlight FloatBorder guifg=]] .. colors.white_bright)
  vim.cmd([[highlight DropBarKindDir gui=italic guifg=]] .. colors.black_bright)
  vim.cmd([[highlight DropBarFileName gui=bold guifg=]] .. colors.red_bright)

  -- Diagnostic underline colors for red squiggles
  -- Use both undercurl and underline for better terminal compatibility
  vim.cmd([[highlight DiagnosticUnderlineError guisp=]] .. colors.red_bright .. [[ guifg=]] .. colors.red_bright .. [[ gui=undercurl,underline]])
  vim.cmd([[highlight DiagnosticUnderlineWarn guisp=]] .. colors.yellow_bright .. [[ guifg=]] .. colors.yellow_bright .. [[ gui=undercurl,underline]])
  vim.cmd([[highlight DiagnosticUnderlineInfo guisp=]] .. colors.blue_bright .. [[ guifg=]] .. colors.blue_bright .. [[ gui=undercurl,underline]])
  vim.cmd([[highlight DiagnosticUnderlineHint guisp=]] .. colors.cyan_bright .. [[ guifg=]] .. colors.cyan_bright .. [[ gui=undercurl,underline]])

  -- Comments: shadow ships them as a dim gray-blue (black_bright #485457) that
  -- recedes into the bg. A brighter blue-gray collides with the theme's cyan
  -- (#839C98) / blue (#7E9AAB) syntax tokens, so use a NEUTRAL gray instead:
  -- readable off the dark bg, but hueless so it can't clash with any colored
  -- token or grab attention. Keep treesitter's @comment in sync (the theme sets
  -- it explicitly rather than linking to Comment).
  local comment_fg = "#8B8E8C"
  vim.api.nvim_set_hl(0, "Comment", { fg = comment_fg })
  vim.api.nvim_set_hl(0, "@comment", { fg = comment_fg })
  vim.api.nvim_set_hl(0, "@comment.documentation", { fg = comment_fg })
  vim.api.nvim_set_hl(0, "TSComment", { fg = comment_fg })

  vim.api.nvim_set_hl(0, "DiffAdd", { bg = shadow.bg_green_dark })
  vim.api.nvim_set_hl(0, "DiffDelete", { bg = shadow.bg_red_dark })
  vim.api.nvim_set_hl(0, "DiffChange", { bg = shadow.bg_blue_bright })
  -- DiffText = the changed chars within a changed line; must read brighter
  -- than DiffChange, not darker.
  vim.api.nvim_set_hl(0, "DiffText", { bg = shadow.bg_blue_text })

  -- vim.cmd([[highlight Cursor guibg=]] .. colors.cursor)
  -- vim.cmd([[highlight Search guibg=]] .. colors.search .. [[ guifg=#000000]])
  -- vim.cmd([[highlight IncSearch guibg=]] .. colors.headerBg .. [[ guifg=#ffffff]])
  -- vim.cmd([[highlight CurSearch guibg=]] .. colors.search .. [[ guifg=#ffffff]])
  -- vim.cmd([[highlight GitSignsCurrentLineBlame guifg=]] .. colors.lineBlame)
  -- vim.cmd([[hi HlSearchLensNear guibg=#bac2de]] .. [[ guifg=]] .. colors.diffBg)
  --
  -- vim.cmd([[highlight MyNormalColor guibg=]] .. colors.macchiato.mantle)
  -- vim.cmd([[highlight DuplicateBuffer guibg=]] .. colors.macchiato.base)
  -- vim.cmd([[hi InclineActive guibg=]] .. colors.mocha.base)
  -- vim.cmd([[hi InclineInactive guibg=]] .. colors.mocha.base)
  -- vim.cmd([[highlight NormalSB guibg=#272e33 ]])
end

colorMyPencils()

-- Ensure diagnostic colors are applied after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Reapply the neutral-gray comment color after any colorscheme change
    local comment_fg = "#8B8E8C"
    vim.api.nvim_set_hl(0, "Comment", { fg = comment_fg })
    vim.api.nvim_set_hl(0, "@comment", { fg = comment_fg })
    vim.api.nvim_set_hl(0, "@comment.documentation", { fg = comment_fg })
    vim.api.nvim_set_hl(0, "TSComment", { fg = comment_fg })

    -- Reapply diagnostic colors after any colorscheme change
    vim.cmd([[highlight DiagnosticUnderlineError guisp=]] .. colors.red_bright .. [[ guifg=]] .. colors.red_bright .. [[ gui=undercurl,underline]])
    vim.cmd(
      [[highlight DiagnosticUnderlineWarn guisp=]] .. colors.yellow_bright .. [[ guifg=]] .. colors.yellow_bright .. [[ gui=undercurl,underline]]
    )
    vim.cmd([[highlight DiagnosticUnderlineInfo guisp=]] .. colors.blue_bright .. [[ guifg=]] .. colors.blue_bright .. [[ gui=undercurl,underline]])
    vim.cmd([[highlight DiagnosticUnderlineHint guisp=]] .. colors.cyan_bright .. [[ guifg=]] .. colors.cyan_bright .. [[ gui=undercurl,underline]])
  end,
})

return colorMyPencils
