return {
  "sindrets/diffview.nvim",
  cond = not vim.g.vscode,
  config = function()
    local actions = require("diffview.actions")
    local lib = require("diffview.lib")

    function activate_win_by_buffer_name()
      local path = lib.get_current_view():infer_cur_file().absolute_path
      if not path then
        actions.goto_file_edit()
      end

      local current_tabpage = vim.api.nvim_get_current_tabpage()
      local tabpages = vim.api.nvim_list_tabpages()
      local emptyBufferId = nil
      for _, tabpage in ipairs(tabpages) do
        local windows = vim.api.nvim_tabpage_list_wins(tabpage)

        for _, win in ipairs(windows) do
          local buf = vim.api.nvim_win_get_buf(win)
          local bufname = vim.api.nvim_buf_get_name(buf)
          if bufname == "" and #tabpages > 1 and #windows == 1 then
            emptyBufferId = buf
          end
          local is_current_tab = tabpage == current_tabpage
          if bufname:match(path) and not is_current_tab then
            -- Activate the tab
            vim.api.nvim_set_current_tabpage(tabpage)
            -- Optionally, activate the window with the matching buffer
            vim.api.nvim_set_current_win(win)

            require("gitsigns").next_hunk()
            vim.cmd([[normal! zz]])

            found = true -- Pattern found and tab activated
          end
        end
      end

      if emptyBufferId then
        vim.api.nvim_buf_delete(emptyBufferId, { force = true })
      end

      if not found then
        if #tabpages == 1 then
          actions.goto_file_tab()

          require("gitsigns").next_hunk()
          vim.cmd([[normal! zz]])
        else
          actions.goto_file_edit()
          require("gitsigns").next_hunk()
          vim.cmd([[normal! zz]])
        end
      end
    end

    -- File-panel l/h: on a directory, expand (l) / collapse (h) it; on a file,
    -- step the diff to the next (l) / previous (h) hunk while the cursor stays
    -- put in the panel — the diff window is driven remotely.
    -- The main diff window for the active view, or nil if the layout isn't ready.
    local function main_diff_win()
      local view = lib.get_current_view()
      if not (view and view.cur_layout and view.cur_layout.get_main_win) then
        return nil
      end
      local main = view.cur_layout:get_main_win()
      if main and main.id and vim.api.nvim_win_is_valid(main.id) then
        return main.id
      end
      return nil
    end

    -- File-panel j/k: scroll the diff buffer by a line without leaving the panel.
    local function panel_scroll(dir)
      local win = main_diff_win()
      if not win then
        return
      end
      local key = dir == "j" and "\5" or "\25" -- <C-e> down / <C-y> up
      vim.api.nvim_win_call(win, function()
        vim.cmd("normal! " .. key)
      end)
    end

    -- File-panel gg / G: jump the diff buffer to top / bottom, focus stays put.
    local function panel_jump(edge)
      local win = main_diff_win()
      if not win then
        return
      end
      local motion = edge == "top" and "gg" or "G"
      vim.api.nvim_win_call(win, function()
        vim.cmd("normal! " .. motion .. "zz")
      end)
    end

    local function panel_hunk_or_fold(dir)
      local view = lib.get_current_view()
      if not (view and view.panel) then
        return
      end

      local item = view.panel:get_item_at_cursor()
      if not item then
        return
      end

      -- A DirData carries a boolean `collapsed`; a FileEntry does not. That's
      -- the same discriminator diffview uses in FilePanel:set_item_fold.
      if type(item.collapsed) == "boolean" then
        view.panel:set_item_fold(item, dir == "l") -- l = open, h = close
        return
      end

      -- File entry: jump hunks in the main diff window without leaving the panel.
      local motion = dir == "l" and "]c" or "[c"
      local function jump_hunk()
        local win = main_diff_win()
        if not win then
          return
        end
        vim.api.nvim_win_call(win, function()
          pcall(vim.cmd, "normal! " .. motion .. "zz")
        end)
      end

      if view.cur_entry ~= item then
        -- Load this file into the diff (focus stays in the panel), then jump.
        view:set_file(item, false, false)
        vim.schedule(jump_hunk)
      else
        jump_hunk()
      end
    end

    local function is_floating(win)
      return vim.api.nvim_win_get_config(win).relative ~= ""
    end

    -- Non-floating windows in a tab (floats like winbar/scrollbar don't count).
    local function content_wins(tabpage)
      local out = {}
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
        if not is_floating(win) then
          table.insert(out, win)
        end
      end
      return out
    end

    -- A tab is "throwaway" when its only non-floating window shows an unnamed,
    -- unmodified buffer — i.e. the startup welcome/intro screen. Floating
    -- windows (winbar, scrollbar, etc.) are ignored.
    local function is_throwaway_tab(tabpage)
      local wins = content_wins(tabpage)
      if #wins ~= 1 then
        return false
      end
      local buf = vim.api.nvim_win_get_buf(wins[1])
      return vim.api.nvim_buf_get_name(buf) == "" and not vim.bo[buf].modified
    end

    function open_diff_view()
      local pattern = "diffview:///panels/0/DiffviewFilePanel"
      -- If a Diffview tab already exists, just focus it.
      for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
          local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
          if bufname:match(pattern) then
            vim.api.nvim_set_current_tabpage(tabpage)
            vim.api.nvim_set_current_win(win)
            return
          end
        end
      end

      -- Remember the tab we launched from so we can drop it if it's a
      -- throwaway. Cleanup is scheduled because DiffviewOpen switches tabs
      -- asynchronously — running it inline would delete the *current* buffer
      -- and just spawn a fresh [No Name] instead of closing the tab.
      local origin_tab = vim.api.nvim_get_current_tabpage()
      local origin_is_throwaway = is_throwaway_tab(origin_tab)

      vim.cmd([[DiffviewOpen]])

      if origin_is_throwaway then
        vim.schedule(function()
          -- Only close if DiffviewOpen actually moved us off the origin tab
          -- and it's still a throwaway.
          if not vim.api.nvim_tabpage_is_valid(origin_tab) then
            return
          end
          if vim.api.nvim_get_current_tabpage() ~= origin_tab and is_throwaway_tab(origin_tab) then
            pcall(vim.api.nvim_win_close, content_wins(origin_tab)[1], true)
          end
        end)
      end
    end

    vim.keymap.set("n", "<leader>gd", open_diff_view, { desc = "open diffview", noremap = true, silent = true })
    vim.keymap.set("n", "<leader>gg", ":DiffviewClose<CR>", { desc = "close diffview", noremap = true, silent = true })

    require("diffview").setup({
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
      keymaps = {
        view = {
          {
            "n",
            "gf",
            actions.goto_file_tab,
            { desc = "Open the file in a new split in the previous tabpage" },
          },
        },
        file_panel = {
          {
            "n",
            "gf",
            activate_win_by_buffer_name,
            { desc = "Open the file in a new split in the previous tabpage" },
          },
          {
            "n",
            "J",
            actions.scroll_view(0.10),
            { desc = "Scroll down" },
          },
          {
            "n",
            "K",
            actions.scroll_view(-0.10),
            { desc = "Scroll up" },
          },
          {
            "n",
            "j",
            function()
              panel_scroll("j")
            end,
            { desc = "Scroll diff down a line" },
          },
          {
            "n",
            "k",
            function()
              panel_scroll("k")
            end,
            { desc = "Scroll diff up a line" },
          },
          {
            "n",
            "gg",
            function()
              panel_jump("top")
            end,
            { desc = "Jump diff to top" },
          },
          {
            "n",
            "G",
            function()
              panel_jump("bottom")
            end,
            { desc = "Jump diff to bottom" },
          },
          {
            "n",
            "l",
            function()
              panel_hunk_or_fold("l")
            end,
            { desc = "Expand folder / next hunk" },
          },
          {
            "n",
            "<Right>",
            function()
              panel_hunk_or_fold("l")
            end,
            { desc = "Expand folder / next hunk" },
          },
          {
            "n",
            "h",
            function()
              panel_hunk_or_fold("h")
            end,
            { desc = "Collapse folder / prev hunk" },
          },
          {
            "n",
            "<Left>",
            function()
              panel_hunk_or_fold("h")
            end,
            { desc = "Collapse folder / prev hunk" },
          },
        },
      },
    })

    -- --- GitHub/delta-style red-left / green-right for in-place edits --------
    -- Neovim's diff engine tags an in-place line change as DiffChange on BOTH
    -- panes, so it reads blue on both sides. To mimic a unified-diff renderer
    -- (old line red, new line green) we give each pane its own DiffChange /
    -- DiffText via window-local winhl. Colors mirror DiffAdd/DiffDelete but the
    -- "*Text" variants are brighter so the changed token pops.
    local function define_change_groups()
      vim.api.nvim_set_hl(0, "DiffChangeDeleteLine", { bg = "#43292D" }) -- old side line (red)
      vim.api.nvim_set_hl(0, "DiffChangeDeleteText", { bg = "#5E353B" }) -- old side changed token
      vim.api.nvim_set_hl(0, "DiffChangeAddLine", { bg = "#28402C" }) -- new side line (green)
      vim.api.nvim_set_hl(0, "DiffChangeAddText", { bg = "#37583D" }) -- new side changed token
    end
    define_change_groups()
    -- Re-assert after a colorscheme swap wipes custom groups.
    vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = define_change_groups })

    local function apply_split_change_hl()
      -- Only the standard 2-way diff; leave merge (diff3) layouts alone.
      local diff_wins = {}
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_is_valid(win) and vim.wo[win].diff then
          table.insert(diff_wins, win)
        end
      end
      if #diff_wins ~= 2 then
        return
      end
      -- Leftmost diff window is the old ("a") side, rightmost is the new ("b").
      table.sort(diff_wins, function(a, b)
        return vim.api.nvim_win_get_position(a)[2] < vim.api.nvim_win_get_position(b)[2]
      end)
      -- Preserve Diffview's add/delete linking (enhanced_diff_hl), override only
      -- the change/text groups so each side gets its own color.
      vim.wo[diff_wins[1]].winhl = table.concat({
        "DiffAdd:DiffviewDiffAddAsDelete",
        "DiffDelete:DiffviewDiffDeleteDim",
        "DiffChange:DiffChangeDeleteLine",
        "DiffText:DiffChangeDeleteText",
      }, ",")
      vim.wo[diff_wins[2]].winhl = table.concat({
        "DiffDelete:DiffviewDiffDeleteDim",
        "DiffAdd:DiffviewDiffAdd",
        "DiffChange:DiffChangeAddLine",
        "DiffText:DiffChangeAddText",
      }, ",")
    end

    -- Re-apply after every (re)layout and whenever a diff buffer enters a
    -- window (file navigation), since Diffview resets winhl each time.
    vim.api.nvim_create_autocmd("User", {
      pattern = { "DiffviewViewPostLayout", "DiffviewDiffBufWinEnter" },
      callback = function()
        vim.schedule(apply_split_change_hl)
      end,
    })
  end,
}
