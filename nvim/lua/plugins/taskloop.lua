-- TASK-LOOP v2 editor front-end. The plugin + its daemon engine live together in
-- the agentic.nvim repo, vendored inside this dotfiles tree (~/.dotfiles/agentic.nvim);
-- the daemon/scripts are symlinked into ~/.claude by its install.sh. Prefix is the hyper
-- key (caps lock -> right_ctrl+right_alt = <C-A->). If a chord doesn't fire (depends on
-- whether ghostty/Karabiner forwards hyper+<letter> to nvim), change `prefix` below to
-- something nvim definitely receives, e.g. "<leader>k".
return {
  dir = vim.fn.expand("~/.dotfiles/agentic.nvim"),
  name = "agentic.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("taskloop").setup({
      prefix = "<C-A-", -- hyper. Try it; fall back to "<leader>k" if the chord is swallowed.
      tail = "split",   -- or "float"
    })
  end,
}
