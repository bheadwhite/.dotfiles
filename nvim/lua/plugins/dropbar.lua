local show_directories = false

if vim.version().minor < 10 then
  return {}
end

local custom_path = {
  get_symbols = function(buff, win, cursor)
    local symbols = require("dropbar.sources").path.get_symbols(buff, win, cursor)
    vim.api.nvim_set_hl(0, "DropBarFileName", { fg = "#FFFFFF", italic = true })

    -- return only last one

    symbols[#symbols].name_hl = "DropBarFileName"
    if vim.bo[buff].modified then
      symbols[#symbols].name = symbols[#symbols].name .. " [+]"
      symbols[#symbols].name_hl = "DiffAdded"
    end

    if show_directories then
      return symbols
    end

    return { symbols[#symbols] }
  end,
}

local handleEnterDropBar = function()
  function cleanup()
    show_directories = false
    require("dropbar.utils").bar.get_current():update()
  end

  cleanup()

  show_directories = true
  require("dropbar.utils").bar.get_current():update()

  vim.defer_fn(function()
    -- pick
    require("dropbar.api").pick()
    vim.defer_fn(cleanup, 1000)
  end, 100)
end

vim.keymap.set("n", "<leader>b", handleEnterDropBar, { noremap = true, silent = true })

return {
  "Bekaboo/dropbar.nvim",
  dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
  opts = {
    bar = {
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
      ui = {
        bar = {
          separator = " → ",
        },
      },
      kinds = {
        symbols = {
          Folder = "",
        },
      },
    },
  },
}
