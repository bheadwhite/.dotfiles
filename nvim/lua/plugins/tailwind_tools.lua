if vim.version().minor < 10 then
  return {}
end

return {}

-- return {
--   "luckasRanarison/tailwind-tools.nvim",
--   name = "tailwind-tools",
--   build = ":UpdateRemotePlugins",
--   dependencies = {
--     "nvim-treesitter/nvim-treesitter",
--     "nvim-telescope/telescope.nvim", -- optional
--   },
--   config = function()
--     -- require("tailwind-tools").setup({
--     --
--     -- })
--
--     local function file_exists(name)
--       local f = io.open(name, "r")
--       if f ~= nil then
--         io.close(f)
--         return true
--       else
--         return false
--       end
--     end
--
--     -- Get the current working directory
--     local cwd = vim.loop.cwd()
--
--     -- only add this if we have a tailwind.config.js file in the root of the project
--     if file_exists(cwd .. "/tailwind.config.js") then
--       -- print("yes")
--       vim.api.nvim_create_autocmd("BufWritePre", {
--         pattern = "*.css,*.scss,*.sass,*.less,*.styl,*.html,*.js,*.ts,*.jsx,*.tsx,*.vue",
--         callback = function()
--           vim.cmd("TailwindSortSync")
--         end,
--       })
--     else
--       -- print("no")
--     end
--   end,
-- }
