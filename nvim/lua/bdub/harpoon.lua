local harpoon_ok, harpoon = pcall(require, "harpoon")
if not harpoon_ok then
  return
end

harpoon.setup {
  menu = {
    width = vim.api.nvim_win_get_width(0) - 4,
  },
}

vim.cmd [[
  augroup _harpoon
    autocmd FileType harpoon setlocal wrap
  augroup end
]]
