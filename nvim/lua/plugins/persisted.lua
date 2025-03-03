if vim.version().minor < 10 then
  return {}
end

return {
  "olimorris/persisted.nvim",
  lazy = false,
  config = function()
    require("persisted").setup({
      autoload = true,
      on_autoload_no_session = function()
        require("notify").notify("no session found....")
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistedLoadPost",
      callback = function()
        --remove buffers that dont exist

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local bufname = vim.api.nvim_buf_get_name(buf)
          if bufname ~= "" and not vim.loop.fs_stat(bufname) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end,
    })
  end,
}
