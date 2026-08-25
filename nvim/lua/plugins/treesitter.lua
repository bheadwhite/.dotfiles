local treesitter_main = {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
}

if vim.version().minor < 10 then
  treesitter_main.tag = "v0.9.3"
end

return {
  treesitter_main,
  {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false, -- Load with treesitter (not lazy)
    config = function()
      require("treesitter-modules").setup({
        ensure_installed = { "lua", "typescript", "javascript", "tsx", "html", "css", "json", "yaml", "go", "svelte" },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = false,
          },
        },
        highlight = {
          enable = true,
        },
      })
      -- Does the current buffer have a live Treesitter parser? (get_parser
      -- returns nil / errors for filetypes with no grammar, e.g. `.env`.)
      local function has_ts_parser()
        local ok, parser = pcall(vim.treesitter.get_parser, 0)
        return ok and parser ~= nil
      end

      -- Fallback "expand selection" for parser-less buffers: instead of walking
      -- syntax nodes, walk a ladder of native text objects. Level is tracked in
      -- a buffer-local so repeated presses grow (and <C-M-i> shrinks) the region.
      -- For `.env`: word (API_KEY) -> WORD (API_KEY=abc123) -> line -> block -> file.
      local expand_ladder = { "viw", "viW", "V", "Vip", "ggVG" }
      local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
      local function apply_level(lvl)
        vim.b.expand_level = lvl
        -- Esc first so we re-select cleanly whether we start in normal or visual.
        vim.cmd("normal! " .. esc .. expand_ladder[lvl])
      end
      local function fallback_expand()
        apply_level(math.min((vim.b.expand_level or 0) + 1, #expand_ladder))
      end
      local function fallback_shrink()
        apply_level(math.max((vim.b.expand_level or 1) - 1, 1))
      end

      vim.keymap.set("n", "<C-M-O>", function()
        if has_ts_parser() then
          if vim.api.nvim_buf_line_count(0) > 0 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] ~= "" then
            require("treesitter-modules").init_selection()
          end
        else
          vim.b.expand_level = 0
          fallback_expand()
        end
      end)

      vim.keymap.set("x", "<C-M-O>", function()
        if has_ts_parser() then
          require("treesitter-modules").node_incremental()
        else
          fallback_expand()
        end
      end)
      -- Shrink is the i/o companion to the <C-M-O> expand key. wezterm's enhanced
      -- keyboard protocol delivers <C-M-i> as a distinct key (not <Tab>), so this
      -- works as long as nothing else claims visual <c-m-i> (sidekick used to).
      vim.keymap.set("x", "<C-M-i>", function()
        if has_ts_parser() then
          require("treesitter-modules").node_decremental()
        else
          fallback_shrink()
        end
      end)

    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("treesitter-context").setup({
        max_lines = 8, -- cap total sticky context height (leave room for multi-line headers)
        multiline_threshold = 20, -- show full multi-line headers (e.g. method chains like ctl.ForPath(...).Exec(...))
        trim_scope = "outer", -- when over max_lines, drop the outermost scopes first
        mode = "cursor", -- context reflects where the cursor is, not just the topline
      })
      -- Jump up to the context header of the current scope
      vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { silent = true, desc = "Jump to context" })
      -- Toggle the sticky context line
      vim.keymap.set("n", "<leader>tc", "<cmd>TSContextToggle<CR>", { silent = true, desc = "Toggle TS context" })
    end,
  },
}
