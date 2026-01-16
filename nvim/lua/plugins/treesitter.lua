local opts = {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
}

if vim.version().minor < 10 then
  opts.tag = "v0.9.3"
end

return opts
