if vim.version().minor < 10 then
  return {}
end

return {
  "olimorris/persisted.nvim",
  lazy = false,
  config = function()
    require("persisted").setup({
      autoload = true,
    })
  end,
}
