-- Declare a global function to retrieve the current directory
function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    -- If there is no current directory (e.g. over ssh), just show the buffer name
    return vim.api.nvim_buf_get_name(0)
  end
end

return {
  "stevearc/oil.nvim",
  config = function()
    local oil = require("oil")
    local oil_config = require("bdub.oil_config")
    oil.setup({
      win_options = {
        winbar = "%!v:lua.get_oil_winbar()",
      },
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["<C-j>"] = false,
        ["<C-k>"] = false,
        ["<C-v>"] = oil_config.openFileAndSwap,
        ["<C-S-S>"] = function()
          require("oil.actions").select_split()
        end,
        ["<C-M-r>"] = function()
          local relative = oil_config.getCursorRelativePath()
          local custom_commands = require("bdub.commands")

          custom_commands.copy_operator_file_path(relative)
        end,
        ["F"] = function()
          local entry = oil.get_cursor_entry()
          local dir = oil.get_current_dir()

          if entry.type == "directory" then
            dir = dir .. entry.name
          end

          require("telescope").extensions.live_grep_args.live_grep_args({
            prompt_title = "ripgrep search in " .. dir,
            search_dirs = { dir },
          })
        end,
        ["L"] = function()
          local dir = oil.get_current_dir()

          vim.cmd([[QFListFilesUnderDir ]] .. dir)
        end,
        ["f"] = function()
          local entry = oil.get_cursor_entry()
          local dir = oil.get_current_dir()

          if entry.type == "directory" then
            dir = dir .. entry.name
          end

          require("telescope.builtin").find_files({
            prompt_title = "file search within " .. dir,
            search_dirs = { dir },
          })
        end,
      },
    })

    -- close deleted files via oil.nvim
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilActionsPost",
      callback = function(args)
        local parse_url = function(url)
          return url:match("^.*://(.*)$")
        end

        if args.data.err then
          return
        end

        for _, action in ipairs(args.data.actions) do
          if action.type == "delete" and action.entry_type == "file" then
            local path = parse_url(action.url)
            local bufnr = vim.fn.bufnr(path)
            if bufnr == -1 then
              return
            end

            local winnr = vim.fn.win_findbuf(bufnr)[1]
            if not winnr then
              return
            end

            vim.fn.win_execute(winnr, "bfirst | bw " .. bufnr)
          end
        end
      end,
    })

    vim.keymap.set("n", "-", function()
      vim.cmd("Oil")
    end, { noremap = true, desc = "open oil" })

    function is_oil_buffer()
      local buf_name = vim.api.nvim_buf_get_name(0)
      return buf_name:find("^oil://") ~= nil
    end

    vim.keymap.set("n", "<leader>e", function()
      if is_oil_buffer() then
        -- If we're in an oil buffer, close it
        require("oil").close()
        --clear any deleted buffers in buf list
        local bufnrs = vim.api.nvim_list_bufs()
        for _, bufnr in ipairs(bufnrs) do
          --does buf exist on disk?
          local exists = vim.loop.fs_stat(vim.api.nvim_buf_get_name(bufnr))
          if not exists and vim.api.nvim_buf_is_loaded(bufnr) then
            -- If the buffer doesn't exist on disk and is loaded, close it
            vim.api.nvim_buf_delete(bufnr, { force = true })
          end
        end
      else
        -- Otherwise, open oil
        vim.cmd("Oil")
      end
    end)
  end,
}
