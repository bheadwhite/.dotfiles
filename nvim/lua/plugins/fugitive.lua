return {
  "tpope/vim-fugitive",
  init = function()
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "git status" })

    local fugitive = vim.api.nvim_create_augroup("Fugitive", {})
    local autocmd = vim.api.nvim_create_autocmd
    autocmd("BufWinEnter", {
      group = fugitive,
      pattern = "*",
      callback = function()
        if vim.bo.ft ~= "fugitive" then
          return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "<leader>gp", function()
          vim.cmd.Git("push")
        end, vim.tbl_extend("force", opts, { desc = "git push" }))

        -- rebase always
        vim.keymap.set("n", "<leader>gP", function()
          vim.cmd.Git({ "pull" })
        end, vim.tbl_extend("force", opts, { desc = "git pull" }))

        -- NOTE: It allows me to easily set the branch i am pushing and any tracking
        -- needed if i did not set the branch up correctly
        vim.keymap.set("n", "<leader>gt", ":Git push -u origin ", vim.tbl_extend("force", opts, { desc = "git push -u origin" }))
      end,
    })
  end,
}
