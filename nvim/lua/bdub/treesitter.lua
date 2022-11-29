local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

configs.setup {
  ensure_installed = "all", -- one of "all" or a list of languages
  ignore_install = { "" }, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "css" }, -- list of language that will be disabled
  },
  autopairs = {
    enable = true,
  },
  indent = { enable = true, disable = { "python", "css" } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-M-S-j>", -- maps in normal mode to init the node/scope selection
      node_incremental = "<C-M-S-j>", -- increment to the upper named parent
      scope_incremental = "<Tab>",
      node_decremental = "<C-M-S-k>", -- decrement to the previous node
    },
  },
}
