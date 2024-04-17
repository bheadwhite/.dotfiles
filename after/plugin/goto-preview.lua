local goto_preview = require("goto-preview")

local file_name_only = function(_, file_path)
  return string.gsub(file_path, ".*/(.*)$", "%1")
end

goto_preview.setup({
    height = 20,
    width = 150,
    references = {
        telescope = require("telescope.themes").get_dropdown({
            path_display = file_name_only,
            layout_strategy = "vertical",
            show_line = false,
            layout_config = {
                height = 0.9,
                width = 0.8,
                preview_cutoff = 60,
            },
        }),
    },
})

-- vim.keymap.set("n", "gpd", goto_preview.goto_preview_definition, { noremap = true, silent = true })
-- vim.keymap.set("n", "gpi", goto_preview.goto_preview_implementation, { noremap = true, silent = true })
-- vim.keymap.set("n", "gP", goto_preview.close_all_win, { noremap = true, silent = true })
-- vim.keymap.set("n", "gpr", goto_preview.goto_preview_references, { noremap = true, silent = true })
-- vim.keymap.set("n", "gpt", goto_preview.goto_preview_type_definition, { noremap = true, silent = true })
