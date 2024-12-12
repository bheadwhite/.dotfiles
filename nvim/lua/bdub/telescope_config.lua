-- after loaded
local telescope = require("telescope")
local previewers = require("telescope.previewers")
local builtin = require("telescope.builtin")

telescope.load_extension("fzf")
telescope.load_extension("ui-select")
telescope.load_extension("live_grep_args")
telescope.load_extension("grapple")
telescope.load_extension("aerial")
telescope.load_extension("dap")

local delta_bcommits = previewers.new_termopen_previewer({
  get_command = function(entry)
    return {
      "git",
      "-c",
      "core.pager=delta",
      "-c",
      "delta.side-by-side=false",
      "diff",
      entry.value .. "^!",
      "--",
      entry.current_file,
    }
  end,
})

local delta = previewers.new_termopen_previewer({
  get_command = function(entry)
    if entry.status == "??" or "A " then
      return { "git", "-c", "core.pager=delta --pager=less", "diff", entry.value }
    end

    return { "git", "-c", "core.pager=delta --pager=less", "diff", entry.value .. "^!" }
  end,
})

Delta_status = function(opts)
  opts = opts or {}
  opts.initial_mode = "normal"
  opts.previewer = {
    delta,
    previewers.git_commit_message.new(opts),
    previewers.git_commit_diff_as_was.new(opts),
  }
  opts.layout_strategy = "vertical"
  opts.layout_config = {
    horizontal = {
      preview_width = 0.7,
    },
    vertical = {
      preview_height = 0.8,
    },
  }
  builtin.git_status(opts)
end

Delta_git_bcommits = function(opts)
  opts = opts or {}
  opts.previewer = {
    delta_bcommits,
    previewers.git_commit_message.new(opts),
    previewers.git_commit_diff_as_was.new(opts),
  }
  builtin.git_bcommits(opts)
end

vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "find files" })
-- vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "git files" })
vim.keymap.set("n", "<leader>p", builtin.oldfiles, { desc = "recent files" })
vim.keymap.set("n", "<leader>Tr", builtin.registers, { desc = "registers" })
vim.keymap.set("n", "<leader>Tq", builtin.quickfixhistory, { desc = "qfhistory" })
-- vim.keymap.set("n", "<leader>gh", Delta_git_bcommits, { desc = "git history" })
-- vim.keymap.set("n", "<leader>gl", Delta_status, { desc = "git status" })
vim.keymap.set("n", "<leader>s", function()
  require("telescope").extensions.live_grep_args.live_grep_args()
end, { desc = "live grep args" })
