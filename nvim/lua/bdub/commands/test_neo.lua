local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local harpoon_tmux = require "harpoon.tmux"

local dropdown_theme = require("telescope.themes").get_dropdown { previewer = false, layout_config = {
  width = 800,
} }

local fire_handle = function(filename)
  harpoon_tmux.sendCommand(
    1,
    "kitty @ launch --keep-focus --type=window --title='NEO_TESTER' --copy-env --cwd=current yarn operator test skill_proficiencies"
  )
  harpoon_tmux.gotoTerminal(1)
end

M.run_coverage_on_dir = function()
  local options = {
    prompt_title = "Select directory to run test coverage in",
    sorter = conf.generic_sorter(),
    finder = finders.new_oneshot_job { "fd", "--type", "d" },
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()

        fire_handle "blah"
        actions.close(prompt_bufnr)

        -- if string.find(file_path, "commons/ui") then
        -- elseif string.find(file_path, "ui/operator/src") then
        -- end

        --
      end)

      return true
    end,
  }

  pickers.new(dropdown_theme, options):find()
end

M.run_coverage = function() end

return M
