local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local harpoon_keymaps = require "bdub.whichkey.harpoon"
local gitsigns_keymaps = require "bdub.whichkey.gitsigns"
local diffview_keymaps = require "bdub.whichkey.diffview"
local telescope_keymaps = require "bdub.whichkey.telescope"
local buffers_keymaps = require "bdub.whichkey.buffers"

local commands = {
  lsp = {
    code_action = "<cmd>lua vim.lsp.buf.code_action()<cr>",
  },
  undo_tree = {
    toggle = "<cmd>UndotreeToggle<cr>",
  },
}

local map_configs = {
  undo_tree = {
    toggle = { commands.undo_tree.toggle, "Undo Tree" },
  },
  lsp = {
    code_action = { commands.lsp.code_action, "Code Action" },
  },
}

local mappings = {
  b = telescope_keymaps.buffers,
  f = telescope_keymaps.find_files,
  p = telescope_keymaps.recent_files,
  F = telescope_keymaps.live_grep,
  c = buffers_keymaps.close,
  P = buffers_keymaps.get_path,
  h = buffers_keymaps.nohl,
  w = buffers_keymaps.write,
  z = buffers_keymaps.zoom,
  o = buffers_keymaps.close_all_but_this_one,
  e = buffers_keymaps.toggle_tree,
  r = buffers_keymaps.rename_file,
  q = buffers_keymaps.quit,
  u = map_configs.undo_tree.toggle,
  ["."] = map_configs.lsp.code_action,
  k = {
    name = "harpoon",
    l = harpoon_keymaps.ui,
    k = harpoon_keymaps.go_next,
    j = harpoon_keymaps.go_prev,
    a = harpoon_keymaps.add_file,
  },
  d = {
    name = "+DiffView",
    d = diffview_keymaps.open_diffview,
    q = diffview_keymaps.close_diffview,
    o = diffview_keymaps.choose_ours,
    t = diffview_keymaps.choose_theirs,
    b = diffview_keymaps.choose_base,
    a = diffview_keymaps.choose_all,
    r = diffview_keymaps.restore_entry,
    s = diffview_keymaps.toggle_stage_entry,
    x = diffview_keymaps.choose_none,
  },
  g = {
    name = "Git",
    d = diffview_keymaps.open_diffview,
    c = diffview_keymaps.close_diffview,
    -- S = { cmd_pre.telescope .. ".git_status()<cr>", "git status" },
    l = gitsigns_keymaps.blame,
    r = gitsigns_keymaps.reset_hunk,
    R = gitsigns_keymaps.reset_buffer,
    s = gitsigns_keymaps.stage_hunk,
    p = gitsigns_keymaps.preview_hunk,
    u = gitsigns_keymaps.undo_stage_hunk,
    D = gitsigns_keymaps.diff,
    -- b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
  },
  l = {
    name = "LSP",
    i = telescope_keymaps.lsp_implementations,
    S = telescope_keymaps.document_symbols,
    e = telescope_keymaps.diagnostics,
    d = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "declaration" },
    s = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "signature help" },
    l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
    q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
    R = { "<cmd>lua require'nvim-lsp-ts-utils'.rename_file()<cr>", "rename file" },
    r = {
      name = "reference",
      s = telescope_keymaps.definitions_split,
      v = telescope_keymaps.definitions_vsplit,
    },
  },
  L = {
    name = "LSP config",
    f = { "<cmd>lua vim.lsp.buf.format{async=true}<cr>", "Format" },
    s = telescope_keymaps.document_symbols,
    S = telescope_keymaps.workspace_symbols,
  },
  s = {
    name = "Search",
    f = {
      "<cmd>lua require 'bdub.commands.search'.find_files_within_directories()<CR>",
      "find files within directories",
    },
    F = {
      "<cmd>lua require 'bdub.commands.search'.grep_files_within_directories()<CR>",
      "grep files within direcotries",
    },
    b = telescope_keymaps.checkout_branch,
    c = telescope_keymaps.colorscheme,
    h = telescope_keymaps.help_tags,
    M = telescope_keymaps.man_pages,
    r = telescope_keymaps.recent_files,
    R = telescope_keymaps.registers,
    k = telescope_keymaps.keymaps,
    C = telescope_keymaps.commands,
  },
  T = {
    name = "Terminal",
    n = { "<cmd>lua _NODE_TOGGLE()<cr>", "Node" },
    f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
    h = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", "Horizontal" },
    v = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", "Vertical" },
  },
}

local normal_opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local visual_opts = {
  mode = "v", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

which_key.setup {}
which_key.register(mappings, normal_opts)
which_key.register(mappings, visual_opts)
