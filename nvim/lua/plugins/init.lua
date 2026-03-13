local function getColors()
  return require("bdub.catppuccin_colors")
end

return {
  { "tpope/vim-abolish", "tpope/vim-surround" },
  { "tpope/vim-dispatch", event = "VeryLazy" },
  { "nvim-zh/better-escape.vim", event = "InsertEnter" }, -- better escape from insert mode
  { "folke/ts-comments.nvim" },
  { "fei6409/log-highlight.nvim" },
  { "mileszs/ack.vim" }, -- Integrates 'ack' search tool
  { "stevearc/dressing.nvim" }, -- Improved UI components
  {
    "neovim/nvim-lspconfig",
  },
  { "AckslD/messages.nvim", config = true, cond = not vim.g.vscode }, -- messages
  { "sbulav/nredir.nvim" }, -- Redirects command output
  {
    "windwp/nvim-ts-autotag",
    cond = not vim.g.vscode,
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true, -- Auto close tags
          enable_rename = false, -- Auto rename pairs of tags
          enable_close_on_slash = true, -- Auto close on trailing </
        },
        -- Override individual filetype configurations if needed
        per_filetype = {
          ["html"] = {
            enable_close = true,
          },
        },
      })
    end,
  }, -- Auto-closes HTML tags
  {
    "dmmulroy/tsc.nvim", -- Typescript
    cond = not vim.g.vscode,
    opts = {
      bin_name = "tsgo",
      -- use_diagnostics = true, //populates the diagnostics list with the resulting tsc errors
      -- run_as_monorepo = true,

      -- if TSC runs and your expecting results but there arent any..
      -- it could be that your getting the "this is not the TSC your looking for" error when running TSC
      -- find the path to the tsc bin by running require("tsc.utils").find_tsc_bin()
      -- troubleshoot why thats not running as a standalone
      -- references:
      -- https://stackoverflow.com/questions/69080861/error-running-a-npx-tsc-command-regarding-typescript-this-is-not-the-tsc-comm
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    build = "make tiktoken",
    cond = not vim.g.vscode,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("CopilotChat").setup()
    end,
  },
  {
    "nvim-zh/colorful-winsep.nvim",
    config = function()
      require("colorful-winsep").setup()
      vim.cmd([[highlight NvimSeparator guifg=]] .. getColors().mocha.overlay0)
    end,
    cond = not vim.g.vscode,
    event = { "WinLeave" },
  },
}
