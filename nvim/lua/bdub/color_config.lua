local colors = require("bdub.catppuccin_colors")

vim.cmd([[highlight MyNormalColor guibg=]] .. colors.macchiato.mantle)
vim.cmd([[highlight MyInactiveBufferColor guibg=]] .. colors.mocha.mantle)
vim.cmd([[highlight MyZoomedBufferColor guibg=]] .. colors.macchiato.mantle)
vim.cmd([[highlight DuplicateBuffer guibg=]] .. colors.macchiato.base)
vim.cmd([[highlight DropBarFileName guifg=]] .. colors.mocha.sky)
vim.cmd([[highlight DropBarKindDir gui=bold,italic guifg=]] .. colors.mocha.peach)
vim.cmd([[hi InclineActive guibg=]] .. colors.mocha.base)
vim.cmd([[hi InclineInactive guibg=]] .. colors.mocha.base)
vim.cmd([[highlight NormalSB guibg=#272e33 ]])

return {
  search = colors.mocha.red,
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
  winseperator = "#000000",
  cursorLine = "#653A45",
  cursor = "#FFFFFF",
  lineBlame = "#FFFFFF",
}
