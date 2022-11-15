local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

bufferline.setup {
  options = {
    max_name_length = 35,
    max_prefix_length = 30,
    tab_size = 30,
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = true,
    show_close_icon = false,
    show_buffer_close_icons = false,
    -- offsets = { { filetype = "NvimTree", text = "", padding = 1 } },
    -- show_buffer_close_icons = false,
    -- show_close_icon = false,
    -- persist_buffer_sort = true,
    -- separator_style = "thick",
    enforce_regular_tabs = true,
    always_show_bufferline = true,
  },
}
