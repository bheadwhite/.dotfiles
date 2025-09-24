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

function colorMyPencils()
  vim.cmd([[highlight WinSeparator guifg=]] .. colors.bg)
  vim.cmd([[highlight CursorLine guibg=]] .. colors.deep_blue)
  vim.cmd([[highlight QuickFixLine guibg=]] .. colors.dark)
  vim.cmd([[highlight Visual guibg=]] .. colors.white .. [[ guifg=]] .. colors.black)
  vim.cmd([[highlight MyInactiveBufferColor guibg=]] .. colors.black)
  vim.cmd([[highlight Winbar guibg=]] .. colors.bg .. [[ guifg=]] .. colors.white_bright)
  vim.cmd([[highlight WinbarNC guibg=]] .. colors.black .. [[ guifg=]] .. colors.white_bright)
  vim.cmd([[highlight DropbarHover guibg=]] .. colors.bg .. [[ guifg=]] .. colors.white_bright)
  vim.cmd([[highlight DropbarCurrentContext guibg=]] .. colors.bg .. [[ guifg=]] .. colors.white_bright)
  vim.cmd([[highlight FloatBorder guifg=]] .. colors.white_bright)
  vim.cmd([[highlight DropBarKindDir gui=italic guifg=]] .. colors.black_bright)
  vim.cmd([[highlight DropBarFileName gui=bold guifg=]] .. colors.red_bright)

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

return colorMyPencils
