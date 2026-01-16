-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.localleader = ","

-- Temporarily suppress deprecation warnings from external plugins
-- These will be addressed when the plugins are updated by their maintainers
vim.deprecate = function() end

local luarocksPath = os.getenv("LUAROCKS_PATH") or ""

if luarocksPath ~= "" then
  package.path = package.path .. ";" .. luarocksPath .. "/share/lua/5.1/?.lua"
end

require("bdub.options")
require("bdub.remap")
require("bdub.autocommands")
require("bdub.inactive_backgrounds")
require("bdub.buf-only")

-- Setup lazy.nvim
require("lazy").setup({
  spec = { -- import your plugins
    {
      import = "plugins",
    },
  },
  -- automatically check for plugin updates
  checker = {
    enabled = true,
  },
})

if vim.g.vscode then
  require("bdub.vscode_keymaps")
  vim.opt.cmdheight = 1
else
  vim.keymap.set("n", "<leader>t", function()
    local ok, tsc = pcall(require, "tsc")
    if not ok then
      vim.notify("tsc.nvim plugin not available", vim.log.levels.WARN)
      return
    end
    tsc.run()
  end, {
    desc = "Run TypeScript compiler",
  })

  vim.api.nvim_create_user_command("CursorQF", function()
    require("bdub.commands").open_qf_in_cursor()
  end, {
    desc = "Run TypeScript compiler and open errors in Cursor",
  })

  function dedupe_quickfix()
    local qf_list = vim.fn.getqflist()
    if #qf_list == 0 then
      vim.notify("Quickfix list is empty", vim.log.levels.INFO)
      return
    end

    local seen_files = {}
    local deduped_list = {}

    for _, item in ipairs(qf_list) do
      local bufnr = item.bufnr
      local filename = vim.api.nvim_buf_get_name(bufnr)

      if not seen_files[filename] then
        seen_files[filename] = true
        table.insert(deduped_list, item)
      end
    end

    vim.fn.setqflist(deduped_list, "r")
    vim.notify(string.format("Deduped quickfix: %d -> %d items", #qf_list, #deduped_list), vim.log.levels.INFO)
  end

  vim.keymap.set("n", "<leader>c", function()
    dedupe_quickfix()
    vim.cmd("CursorQF")
  end, {
    noremap = true,
    silent = true,
    desc = "Run TypeScript compiler and open errors in Cursor",
  })

  vim.keymap.set("n", "<leader>-", "<cmd>CursorQF<CR>", {
    noremap = true,
    silent = true,
    desc = "Run TypeScript compiler and open errors in Cursor",
  })
end
