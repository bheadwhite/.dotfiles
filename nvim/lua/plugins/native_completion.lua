-- Native completion configuration for Neovim 0.11+
-- Replaces nvim-cmp with built-in vim.lsp.completion

local function setup_native_completion()
  -- Update completeopt for better native completion experience
  -- Keep "noselect" so nothing is pre-selected (user maintains freedom to choose)
  -- Add "preview" to show documentation in a preview window
  vim.opt.completeopt = { "menu", "menuone", "noselect", "preview" }
  
  -- Set up completion keymaps
  local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- Check if completion menu is visible
  local function completion_visible()
    return vim.fn.pumvisible() == 1
  end

  -- Handle completion navigation and acceptance  
  local function handle_cr()
    local is_visible = completion_visible()
    
    if is_visible then
      -- Always ensure something is selected before accepting (like cmp behavior)
      -- This approach: try to go to first item, then back, then accept
      -- If something was already selected, this should preserve it
      return "<C-n><C-p><C-y>"
    else
      -- No completion menu, insert newline
      return "<CR>"
    end
  end

  local function handle_ctrl_v()
    -- Check for Copilot suggestion first
    local copilot_ok, copilot = pcall(require, "copilot.suggestion")
    if copilot_ok and copilot.is_visible() then
      copilot.accept()
      return ""
    end
    
    if completion_visible() then
      -- Same logic as Enter: force select first item then accept
      return "<C-n><C-y>"
    else
      -- No completion, fallback to normal Ctrl+V
      return "<C-v>"
    end
  end

  local function handle_ctrl_n()
    if completion_visible() then
      return "<C-n>"  -- Select next item
    else
      return "<C-x><C-o>"  -- Trigger completion
    end
  end

  local function handle_ctrl_p()
    if completion_visible() then
      return "<C-p>"  -- Select previous item
    else
      return "<C-x><C-o>"  -- Trigger completion
    end
  end

  local function handle_down()
    if completion_visible() then
      return "<C-n>"
    else
      return "<Down>"
    end
  end

  local function handle_up()
    if completion_visible() then
      return "<C-p>"
    else
      return "<Up>"
    end
  end

  -- Set up keymaps for insert mode
  
  map("i", "<CR>", handle_cr, { expr = true, desc = "Accept completion or newline" })
  map("i", "<C-v>", handle_ctrl_v, { expr = true, desc = "Accept Copilot or completion" })
  map("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger completion" })
  map("i", "<M-Space>", "<C-x><C-o>", { desc = "Trigger completion" })
  map("i", "<C-e>", "<C-e>", { desc = "Close completion menu" })
  map("i", "<C-n>", handle_ctrl_n, { expr = true, desc = "Next completion or trigger" })
  map("i", "<C-p>", handle_ctrl_p, { expr = true, desc = "Previous completion or trigger" })
  map("i", "<Up>", handle_up, { expr = true, desc = "Previous completion or up" })
  map("i", "<Down>", handle_down, { expr = true, desc = "Next completion or down" })
  
  -- Alt+j/k for completion navigation (similar to cmp config)
  map("i", "<M-j>", function()
    if completion_visible() then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", false)
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<M-j>", true, false, true), "n", false)
    end
  end, { desc = "Next completion with Alt+j" })
  
  map("i", "<M-k>", function()
    if completion_visible() then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", false)
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<M-k>", true, false, true), "n", false)
    end
  end, { desc = "Previous completion with Alt+k" })

  -- Documentation scrolling (when available)
  map("i", "<C-f>", function()
    if completion_visible() then
      -- Try to scroll documentation if available
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-f>", true, false, true), "n", false)
    end
  end, { desc = "Scroll docs down" })
  
  map("i", "<C-d>", function()
    if completion_visible() then
      -- Try to scroll documentation if available  
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-b>", true, false, true), "n", false)
    end
  end, { desc = "Scroll docs up" })
  
  -- Configure preview window for documentation
  vim.opt.previewheight = 10  -- Set preview window height
  
  -- Set up autopairs integration for native completion
  local npairs_ok, npairs = pcall(require, 'nvim-autopairs')
  if npairs_ok then
    -- Set up autopairs to work with native completion
    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')
    
    -- Add basic autopairs rules that work with native completion
    npairs.add_rules({
      Rule(' ', ' ')
        :with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ '()', '[]', '{}' }, pair)
        end),
      Rule('( ', ' )')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%)') ~= nil
        end)
        :use_key(')'),
      Rule('{ ', ' }')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%}') ~= nil
        end)
        :use_key('}'),
      Rule('[ ', ' ]')
        :with_pair(function() return false end)
        :with_move(function(opts)
          return opts.prev_char:match('.%]') ~= nil
        end)
        :use_key(']')
    })
  end
  
  -- Enhanced completion with documentation
  -- Note: Native completion documentation is limited compared to nvim-cmp
  -- For rich documentation, you might want to use vim.lsp.buf.hover() manually
  
  -- Note: Hover window management is handled in the main setup function below
  
  -- Set up autocmd to automatically close preview window when completion is done
  vim.api.nvim_create_autocmd({ "InsertLeave", "CompleteDone" }, {
    callback = function()
      -- Close preview window when leaving insert mode or completion is done
      pcall(vim.cmd, "pclose")
      
      -- Also close hover window
      if hover_win and vim.api.nvim_win_is_valid(hover_win) then
        vim.api.nvim_win_close(hover_win, true)
        hover_win = nil
      end
    end
  })
end

return {
  -- Native completion configuration for Neovim 0.11+
  -- This creates a pseudo-plugin to set up native completion
  name = "native-completion",
  dir = vim.fn.stdpath("config"), -- dummy directory since this isn't a real plugin
  dependencies = { "windwp/nvim-autopairs" }, -- Load after autopairs
  priority = 2000, -- Higher priority to load after other plugins
  lazy = false, -- Force immediate loading
  config = function()
    -- Delay setup to ensure we override autopairs
    vim.defer_fn(function()
      setup_native_completion()
      
      -- Set up native completion with autopairs integration
      vim.defer_fn(function()
        -- Don't override autopairs' CR mapping - instead integrate with it
        local npairs = require('nvim-autopairs')
        
        -- Track if user has manually navigated in completion
        local user_navigated = false
        local original_text = ""
        local completion_start_col = 0
        
        -- Shared hover window variable that navigation functions can access
        local hover_win = nil
        
        -- Function to close hover window
        local function close_hover_window()
          if hover_win and vim.api.nvim_win_is_valid(hover_win) then
            vim.schedule(function()
              if hover_win and vim.api.nvim_win_is_valid(hover_win) then
                vim.api.nvim_win_close(hover_win, true)
                hover_win = nil
              end
            end)
          end
        end
        
        -- Function to save original text when completion starts
        local function save_original_text()
          if vim.fn.pumvisible() == 0 then  -- Only save if completion isn't already visible
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            -- Find the start of the word being completed
            local word_start = col
            while word_start > 0 and line:sub(word_start, word_start):match('[%w_]') do
              word_start = word_start - 1
            end
            word_start = word_start + 1
            completion_start_col = word_start
            original_text = line:sub(word_start, col + 1)
          end
        end
        
        -- Override completion navigation keys to track user interaction
        vim.keymap.set("i", "<C-n>", function()
          if vim.fn.pumvisible() == 1 then
            user_navigated = true
            return "<C-n>"
          else
            save_original_text()
            return "<C-x><C-o>"
          end
        end, { expr = true })
        
        vim.keymap.set("i", "<C-p>", function()
          if vim.fn.pumvisible() == 1 then
            user_navigated = true
            return "<C-p>"
          else
            return "<C-x><C-o>"
          end
        end, { expr = true })
        
        vim.keymap.set("i", "<Down>", function()
          if vim.fn.pumvisible() == 1 then
            user_navigated = true
            return "<C-n>"
          else
            return "<Down>"
          end
        end, { expr = true })
        
        vim.keymap.set("i", "<Up>", function()
          if vim.fn.pumvisible() == 1 then
            user_navigated = true
            return "<C-p>"
          else
            return "<Up>"
          end
        end, { expr = true })
        
        -- Also track M-j and M-k (Alt+j and Alt+k) like in your original cmp config
        vim.keymap.set("i", "<M-j>", function()
          if vim.fn.pumvisible() == 1 then
            user_navigated = true
            -- Close hover window when navigating
            close_hover_window()
            return "<C-n>"
          else
            return "<M-j>"
          end
        end, { expr = true })
        
        vim.keymap.set("i", "<M-k>", function()
          if vim.fn.pumvisible() == 1 then
            user_navigated = true
            -- Close hover window when navigating
            close_hover_window()
            return "<C-p>"
          else
            return "<M-k>"
          end
        end, { expr = true })
        
        -- Add keymap to show documentation for completion items
        vim.keymap.set("i", "<M-l>", function()
          if vim.fn.pumvisible() == 1 then
            -- Close existing hover window
            close_hover_window()
            
            -- Create a custom hover request with better positioning
            local params = vim.lsp.util.make_position_params()
            
            vim.lsp.buf_request(0, 'textDocument/hover', params, function(err, result, ctx, config)
              if err or not result or not result.contents then
                return
              end
              
              -- Convert hover contents to markdown
              local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
              if vim.tbl_isempty(markdown_lines) then
                return
              end
              
              -- Create buffer for hover content
              local hover_buf = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_lines(hover_buf, 0, -1, false, markdown_lines)
              vim.api.nvim_buf_set_option(hover_buf, 'filetype', 'markdown')
              vim.api.nvim_buf_set_option(hover_buf, 'modifiable', false)
              
              -- Calculate window size and position
              local win_width = math.min(80, vim.o.columns - 10)
              local win_height = math.min(20, #markdown_lines + 2)
              
              -- Position to the right of the cursor, avoiding completion menu
              local cursor_pos = vim.api.nvim_win_get_cursor(0)
              local row = cursor_pos[1] - vim.fn.line('w0') + 1
              local col = vim.fn.col('.') + 25  -- Offset to the right
              
              -- Adjust if window would go off screen
              if col + win_width > vim.o.columns then
                col = vim.o.columns - win_width - 5
              end
              
              -- Create floating window
              hover_win = vim.api.nvim_open_win(hover_buf, false, {
                relative = 'editor',
                width = win_width,
                height = win_height,
                row = row,
                col = col,
                style = 'minimal',
                border = 'rounded',
                focusable = false,
                zindex = 1000,  -- High z-index to appear above completion menu
              })
              
              -- Set window options
              vim.api.nvim_win_set_option(hover_win, 'wrap', true)
              vim.api.nvim_win_set_option(hover_win, 'linebreak', true)
              vim.api.nvim_win_set_option(hover_win, 'conceallevel', 2)
              vim.api.nvim_win_set_option(hover_win, 'concealcursor', 'n')
            end)
          end
        end, { desc = "Show documentation for completion item" })
        
        -- Handle Escape to close completion without inserting
        vim.keymap.set("i", "<Esc>", function()
          if vim.fn.pumvisible() == 1 then
            user_navigated = false  -- Reset flag
            close_hover_window()  -- Also close hover window
            return "<C-e><Esc>"  -- Close completion menu, then normal Esc
          else
            return "<Esc>"
          end
        end, { expr = true })
        
        -- Reset flag when completion menu closes
        vim.api.nvim_create_autocmd("CompleteChanged", {
          callback = function()
            if vim.fn.pumvisible() == 0 then
              user_navigated = false
              close_hover_window()  -- Close hover window when completion closes
            end
          end
        })
        
        -- Create our completion handler that works with autopairs
        local function native_completion_cr()
          if vim.fn.pumvisible() == 1 then
            if user_navigated then
              -- User manually selected something, just accept it
              user_navigated = false  -- Reset for next time
              return vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
            else
              -- Nothing manually selected, select first item then accept
              return vim.api.nvim_replace_termcodes("<C-n><C-y>", true, false, true)
            end
          else
            -- No completion menu - let autopairs handle CR normally
            return npairs.autopairs_cr()
          end
        end
        
        -- Set up the CR mapping with proper autopairs integration
        vim.keymap.set("i", "<CR>", native_completion_cr, { expr = true, replace_keycodes = false })
      end, 500)
    end, 100)
  end,
}
