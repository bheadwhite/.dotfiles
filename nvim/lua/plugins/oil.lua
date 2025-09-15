if vim.g.vscode then
  return {}
end

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
        ["="] = "actions.refresh",
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
            delete_any_deleted_buffers()
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

    function delete_any_deleted_buffers()
      -- This function will delete any buffers that have been deleted from disk
      local bufnrs = vim.api.nvim_list_bufs()
      for _, bufnr in ipairs(bufnrs) do
        --is buf valid
        local bufName = vim.api.nvim_buf_get_name(bufnr)
        local isOil = is_oil_buffer()
        if isOil then
          goto continue -- skip if the buffer is not loaded or is an oil buffer
        end

        local existsOnDisk = vim.loop.fs_stat(bufName) ~= nil
        local isLoaded = vim.api.nvim_buf_is_loaded(bufnr)

        if not existsOnDisk and isLoaded then
          -- If the buffer doesn't exist on disk and is loaded, close it
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end

        ::continue:: -- label to skip to the next iteration
      end
    end

    vim.keymap.set("n", "<leader>e", function()
      if is_oil_buffer() then
        -- If we're in an oil buffer, close it
        require("oil").close()
        delete_any_deleted_buffers()
      else
        -- Otherwise, open oil
        vim.cmd("Oil")
      end
    end)
  end,
}
