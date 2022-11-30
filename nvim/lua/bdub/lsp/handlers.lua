local M = {}
local ts_utils = require "nvim-lsp-ts-utils"

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
  return
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)

local function setupDiagnostics()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    virtual_text = false, -- disable virtual text
    signs = {
      active = signs, -- show signs
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)
end

M.setup = function()
  setupDiagnostics()

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap
  local comands = {
    telescope = "<cmd>lua require 'telescope.builtin'",
  }

  keymap(bufnr, "n", "gt", comands.telescope .. ".lsp_type_definitions()<cr>", opts)
  keymap(bufnr, "n", "gT", comands.telescope .. ".lsp_type_definitions({jump_type = 'vsplit'})<cr>", opts)
  keymap(bufnr, "n", "gr", comands.telescope .. ".lsp_references()<cr>", opts)
  keymap(bufnr, "n", "gR", comands.telescope .. ".lsp_references({jump_type = 'vsplit'})<cr>", opts)
  keymap(bufnr, "n", "gi", comands.telescope .. ".lsp_definitions()<cr>", opts)
  keymap(bufnr, "n", "gI", comands.telescope .. ".lsp_definitions({jump_type = 'vsplit'})<cr>", opts)
  keymap(bufnr, "n", "gH", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap(bufnr, "n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
end

local function lsp_highlights(client)
  local illuminate_ok, illuminate = pcall(require, "illuminate")
  if illuminate_ok then
    illuminate.on_attach(client)
  end
end

M.on_attach = function(client, bufnr)
  if client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
    ts_utils.setup {
      import_all_timeout = 5000,
    }
    ts_utils.setup_client(client)
  end

  if client.name == "sumneko_lua" then
    client.server_capabilities.documentFormattingProvider = false
  end

  lsp_keymaps(bufnr)
  lsp_highlights(client)
end

return M
