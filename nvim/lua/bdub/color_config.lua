local colors = require("bdub.catppuccin_colors")

vim.cmd([[highlight MyNormalColor guibg=]] .. colors.macchiato.mantle)
vim.cmd([[highlight MyInactiveBufferColor guibg=]] .. colors.mocha.mantle)
vim.cmd([[highlight MyZoomedBufferColor guibg=]] .. colors.macchiato.mantle)
vim.cmd([[highlight DuplicateBuffer guibg=]] .. colors.macchiato.base)
vim.cmd([[highlight DropBarFileName guifg=]] .. colors.mocha.subtext1)
vim.cmd([[highlight DropBarKindDir guifg=]] .. colors.mocha.peach .. [[ gui=bold,italic]])
vim.cmd([[hi link CurSearch IncSearch]])
vim.cmd([[hi InclineActive guibg=]] .. colors.mocha.base)
vim.cmd([[hi InclineInactive guibg=]] .. colors.mocha.base)
vim.cmd([[highlight NormalSB guibg=#272e33 ]])

return {
  inclineFileName = colors.mocha.peach,
  tabBar = colors.macchiato.crust,
  outOfBoundsBg = colors.mocha.red,
  inclineActiveFG = "#FFFFFF",
  outOfBoundsFg = "#FFFFFF",
  headerBg = colors.macchiato.base,
  headerFg = "#FFFFFF",
  activeTabBg = colors.macchiato.sapphire,
  activeTabFg = "#FFFFFF",
  diffBg = colors.mocha.mantle,
  diagnosticsBg = colors.mocha.surface0,
  sectionFilePathBg = colors.mocha.overlay0,
  sectionFilePathFg = colors.mocha.crust,
  zoomBg = colors.mocha.red,
  winseperator = colors.mocha.surface0,
}
