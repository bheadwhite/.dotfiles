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
  local tsc = require("tsc")
  tsc.run()
end, {
  desc = "Run TypeScript compiler",
})

vim.api.nvim_create_user_command("CursorQF", function()
  require("bdub.commands").open_qf_in_cursor()
end, {
  desc = "Run TypeScript compiler and open errors in Cursor",
})

vim.keymap.set("n", "<leader>-", "<cmd>CursorQF<CR>", {
  noremap = true,
  silent = true,
  desc = "Run TypeScript compiler and open errors in Cursor",
})
end




