if vim.version().minor < 10 then
  return {}
end

return {
  "nvim-neorg/neorg",
  lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  version = "*", -- Pin Neorg to the latest stable release
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.completion"] = {
          config = {
            engine = "nvim-cmp",
          },
        },
        ["core.dirman"] = {
          config = {
            workspaces = {
              scheduler = "~/Projects/wfm-ui/.norg",
              omnichannel = "~/Projects/omnichannel/.norg",
              attachments = "~/Projects/attachments/.norg",
            },
          },
        },
      },
    })
  end,
}
