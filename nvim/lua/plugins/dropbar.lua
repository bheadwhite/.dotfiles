if vim.version().minor < 10 then
  return {}
end

local custom_path = {
  get_symbols = function(buff, win, cursor)
    local symbols = require("dropbar.sources").path.get_symbols(buff, win, cursor)

    symbols[#symbols].name_hl = "DropBarFileName"
    if vim.bo[buff].modified then
      symbols[#symbols].name_hl = "DiffAdded"
    end

    -- if show_directories then
    -- return vim.list_slice(symbols, 1, #symbols - 1)
    return symbols
    -- end

    -- return only last one
    -- return { symbols[#symbols] }
  end,
}

-- ── Go package name, right-aligned in the winbar ──────────────────────────
-- Shows the `package <name>` of the current Go buffer, flush right in the same
-- dropbar winbar (see wrap_dropbar_with_go_package below).
local go_pkg_cache = {} -- buf -> { tick = changedtick, seg = string }

local function go_package_name(buf)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 64, false)) do
    local name = line:match("^package%s+([%w_]+)")
    if name then
      return name
    end
  end
  return nil
end

local function go_package_segment()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype ~= "go" then
    return ""
  end
  local tick = vim.b[buf].changedtick
  local cached = go_pkg_cache[buf]
  if cached and cached.tick == tick then
    return cached.seg
  end
  local name = go_package_name(buf)
  -- %= pushes to the right edge; %#Grp# ... %* colors then resets.
  local seg = name and ("%=%#DropBarGoPackage# 󰟓 " .. name .. " %*") or ""
  go_pkg_cache[buf] = { tick = tick, seg = seg }
  return seg
end

-- Wrap dropbar's global __call so its returned winbar string gets our
-- right-aligned package segment appended. Because the winbar uses the
-- `%{%v:lua.dropbar()%}` form, the returned string is re-parsed as statusline
-- items, so `%=`/`%#..#` in our segment take effect.
local function wrap_dropbar_with_go_package()
  local mt = getmetatable(_G.dropbar)
  if not mt or mt.__go_pkg_wrapped then
    return
  end
  local orig_call = mt.__call
  mt.__call = function(...)
    local ok, str = pcall(orig_call, ...)
    if not ok then
      return ""
    end
    return str .. go_package_segment()
  end
  mt.__go_pkg_wrapped = true
end

local function set_go_package_hl()
  vim.api.nvim_set_hl(0, "DropBarGoPackage", { link = "Special", default = true })
end

local current_idx = nil
local initial_idx = nil
local current_bar = nil

function activate_top_level_components()
  current_bar = require("dropbar.utils").bar.get_current()
  if not current_bar then
    return
  end

  for _, component in ipairs(current_bar.components) do
    if component.name_hl == "DropBarFileName" then
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
  local success, err = pcall(function()
    local dropbar = require("dropbar.api").get_current_dropbar()

    if dropbar == nil then
      local menu = require("dropbar.utils").menu.get_current()
      if menu == nil or current_bar == nil or current_idx == 1 then
        error("Fallback") -- Trigger fallback action
      end

      current_idx = current_idx - 1
      menu:close()
      current_bar:pick(current_idx)
      return
    end

    if not dropbar.in_pick_mode then
      error("Fallback") -- Trigger fallback action
    end
  end)

  -- If `pcall` catches an error, press "_"
  if not success then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("_", true, true, true), "n", true)
  end
end, { noremap = true, silent = true })

vim.keymap.set("n", "L", function()
  local success, err = pcall(function()
    local dropbar = require("dropbar.api").get_current_dropbar()

    if dropbar == nil then
      local menu = require("dropbar.utils").menu.get_current()
      if menu == nil or current_idx + 1 > initial_idx or current_bar == nil then
        error("Fallback") -- Trigger fallback action
      end

      current_idx = current_idx + 1
      menu:close()
      current_bar:pick(current_idx)
      return
    end

    if not dropbar.in_pick_mode then
      error("Fallback") -- Trigger fallback action
    end
  end)

  -- If `pcall` catches an error, press "$"
  if not success then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("$", true, true, true), "n", true)
  end
end, { noremap = true, silent = true })

return {
  "Bekaboo/dropbar.nvim",
  cond = not vim.g.vscode,
  commit = "d0c78c570db0f5941f85ba54522c0f01427cdf67", --10.0
  dependencies = { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  config = function(_, opts)
    require("dropbar").setup(opts)
    wrap_dropbar_with_go_package()
    set_go_package_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_go_package_hl,
      desc = "Re-apply DropBarGoPackage highlight after colorscheme change",
    })
  end,
  opts = {
    sources = {
      treesitter = {
        max_depth = 0,
      },
      lsp = {
        max_depth = 0,
      },
    },
    menu = {
      win_configs = {
        border = "rounded",
      },
      keymaps = {
        ["l"] = function()
          local utils = require("dropbar.utils")
          local menu = utils.menu.get_current()
          if not menu then
            return
          end
          local cursor = vim.api.nvim_win_get_cursor(menu.win)
          local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
          if component then
            menu:click_on(component, nil, 1, "l")
          end
        end,
        ["h"] = "<C-w>q",
      },
    },
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
