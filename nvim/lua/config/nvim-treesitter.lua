require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true
  },
  incremental_selection = {
    enable = true
  },
  textobjects = {
    enable = true,
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]b"] = "@block.outer",
        ["]c"] = "@call.outer",
        ["]C"] = "@conditional.outer",
        ["]F"] = "@frame.outer",
        ["]p"] = "@parameter.outer",
        ["]s"] = "@scopename.inner",
        ["]S"] = "@statement.outer",
      },
      goto_next_end = {
        ["]f"] = "@function.outer"
      },
      goto_previous_start = {
        ["[f"] = "@function.outer"
      },
      goto_previous_end = {
        ["[f"] = "@function.outer"
      }
    }
  }
}
