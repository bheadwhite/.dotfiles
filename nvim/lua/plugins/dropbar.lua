if vim.version().minor < 10 then
  return {}
end

local custom_path = {
  get_symbols = function(buff, win, cursor)
    local symbols = require("dropbar.sources").path.get_symbols(buff, win, cursor)

    symbols[#symbols].name_hl = "DropBarFileName"
    -- if vim.bo[buff].modified then
    --   symbols[#symbols].name = symbols[#symbols].name .. " [+]"
    --   symbols[#symbols].name_hl = "DiffAdded"
    -- end

    -- if show_directories then
    -- return vim.list_slice(symbols, 1, #symbols - 1)
    return symbols
    -- end

    -- return only last one
    -- return { symbols[#symbols] }
  end,
}

local current_idx = nil
local initial_idx = nil
local current_bar = nil

function activate_top_level_components()
  current_bar = require("dropbar.utils").bar.get_current()
  if not current_bar then
    return
  end

  for _, component in ipairs(current_bar.components) do
    if component.name_hl == "DropBarKindDir" then
      if current_bar.components[component.bar_idx + 1] ~= nil then
        current_idx = component.bar_idx + 1
      else
        current_idx = component.bar_idx
      end
      initial_idx = current_idx
      break
    end
  end
end

function handleEnterDropBarUp()
  local dropbar_t = require("dropbar.utils").bar.get_current()
  if not dropbar_t then
    -- send up key
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, true, true), "n", true)
    return
  end

  activate_top_level_components()
  if not current_bar then
    return
  end

  if not current_idx or current_bar.components[current_idx] == nil then
    return
  end

  current_bar:pick(current_idx)
end

function handleEnterDropBarDown()
  local dropbar_t = require("dropbar.utils").bar.get_current()
  if not dropbar_t then
    -- send up key
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, true, true), "n", true)
    return
  end
  activate_top_level_components()
  if not current_bar then
    return
  end
  if not current_idx or current_bar.components[current_idx] == nil then
    return
  end

  current_bar:pick(current_idx)
end

vim.keymap.set("n", "K", handleEnterDropBarUp, { noremap = true, silent = true })
vim.keymap.set("n", "J", handleEnterDropBarDown, { noremap = true, silent = true })
vim.keymap.set("n", "H", function()
  local dropbar = require("dropbar.api").get_current_dropbar()

  if dropbar == nil then
    local menu = require("dropbar.utils").menu.get_current()
    if menu == nil or current_bar == nil or current_idx == 1 then
      return
    end

    current_idx = current_idx - 1

    menu:close()
    current_bar:pick(current_idx)
    return
  end

  if not dropbar.in_pick_mode then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("_", true, true, true), "n", true)
    return
  end
end, { noremap = true, silent = true })

vim.keymap.set("n", "L", function()
  local dropbar = require("dropbar.api").get_current_dropbar()

  if dropbar == nil then
    local menu = require("dropbar.utils").menu.get_current()
    if menu == nil or current_idx + 1 > initial_idx or current_bar == nil then
      return
    end

    current_idx = current_idx + 1
    menu:close()

    current_bar:pick(current_idx)
    return
  end

  if not dropbar.in_pick_mode then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("$", true, true, true), "n", true)
    return
  end
end, { noremap = true, silent = true })

return {
  "Bekaboo/dropbar.nvim",
  dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
  opts = {
    bar = {
      hover = false,
      sources = function(buf, _)
        local sources = require("dropbar.sources")
        local utils = require("dropbar.utils")
        if vim.bo[buf].ft == "markdown" then
          return {
            custom_path,
            sources.markdown,
          }
        end
        if vim.bo[buf].buftype == "terminal" then
          return {
            sources.terminal,
          }
        end

        return {
          custom_path,
          utils.source.fallback({
            sources.lsp,
            sources.treesitter,
          }),
        }
      end,
    },
    icons = {
      ui = {},
      kinds = {
        symbols = {
          Folder = "",
        },
      },
    },
  },
}
