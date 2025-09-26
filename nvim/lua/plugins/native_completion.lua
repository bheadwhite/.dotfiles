return {
  name = "native-completion",
  dir = vim.fn.stdpath("config"), -- dummy directory since this isn't a real plugin
  dependencies = { 
    "windwp/nvim-autopairs",
    "zbirenbaum/copilot.lua",
  },
  event = "InsertEnter", -- Load when entering insert mode
  config = function()
    -- Update completeopt for better native completion experience
    vim.opt.completeopt = { "menu", "menuone", "noselect", "preview" }

    -- Configure preview window
    vim.opt.previewheight = 10

    -- Helper functions
    local function completion_visible()
      return vim.fn.pumvisible() == 1
    end

    local function map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.silent = opts.silent ~= false
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Clear any conflicting mappings
    pcall(vim.keymap.del, "i", "<C-v>")
    pcall(vim.keymap.del, "n", "<C-v>")

    -- NES integration functions
    local triggerNes = function()
      local ok, nes = pcall(require, "copilot-lsp.nes")
      if not ok then return end
      
      local copilotClient = vim.lsp.get_clients({ name = "copilot" })[1]
      if copilotClient then
        return nes.request_nes(copilotClient)
      end
    end

    local acceptNes = function()
      local ok, nes = pcall(require, "copilot-lsp.nes")
      if not ok then return end
      return nes.apply_pending_nes()
    end

    local isNesActive = function()
      return vim.b[vim.api.nvim_get_current_buf()].nes_state ~= nil
    end

    -- Handle Ctrl-V for Copilot and completion
    local function handle_ctrl_v()
      if isNesActive() then
        acceptNes()
        return ""
      else
        triggerNes()
      end

      local copilot_ok, copilot = pcall(require, "copilot.suggestion")
      if copilot_ok and copilot.is_visible() then
        copilot.accept()
        return ""
      end

      if completion_visible() then
        return vim.api.nvim_replace_termcodes("<C-n><C-y>", true, false, true)
      else
        -- Only trigger Copilot in insert mode
        local mode = vim.api.nvim_get_mode().mode
        if mode == "i" and copilot_ok then
          vim.schedule(function()
            copilot.dismiss()
            local pos = vim.api.nvim_win_get_cursor(0)
            local line = vim.api.nvim_get_current_line()

            vim.api.nvim_set_current_line(line .. " ")
            vim.schedule(function()
              vim.api.nvim_set_current_line(line)
              vim.api.nvim_win_set_cursor(0, pos)

              vim.defer_fn(function()
                if copilot.is_visible() then
                  vim.notify("Copilot suggestions triggered", vim.log.levels.INFO)
                end
              end, 200)
            end)
          end)
        end
        return ""
      end
    end

    -- Set up autopairs integration with navigation tracking
    local npairs_ok, npairs = pcall(require, 'nvim-autopairs')
    local user_navigated = false

    -- Main completion keymaps
    map("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger completion" })
    map("i", "<M-Space>", "<C-x><C-o>", { desc = "Trigger completion" })
    map("i", "<C-e>", "<C-e>", { desc = "Close completion menu" })
    map({"i", "n"}, "<C-v>", handle_ctrl_v, { expr = true, desc = "Accept Copilot or completion" })

    -- Close completion menu when typing closing brackets
    local close_brackets = { '>', ')', '}', ']' }
    for _, bracket in ipairs(close_brackets) do
      map("i", bracket, function()
        if completion_visible() then
          return vim.api.nvim_replace_termcodes("<C-c>" .. bracket, true, false, true)
        else
          return vim.api.nvim_replace_termcodes(bracket, true, false, true)
        end
      end, { expr = true, desc = "Close completion and type " .. bracket })
    end

    -- Navigation keymaps with tracking
    local nav_mappings = {
      ["<C-n>"] = { next = "<C-n>", trigger = "<C-x><C-o>" },
      ["<C-p>"] = { next = "<C-p>", trigger = "<C-x><C-o>" },
      ["<Down>"] = { next = "<C-n>", fallback = "<Down>" },
      ["<Up>"] = { next = "<C-p>", fallback = "<Up>" },
      ["<M-j>"] = { next = "<C-n>", fallback = "<M-j>" },
      ["<M-k>"] = { next = "<C-p>", fallback = "<M-k>" },
    }

    for key, config in pairs(nav_mappings) do
      map("i", key, function()
        if completion_visible() then
          user_navigated = true
          return vim.api.nvim_replace_termcodes(config.next, true, false, true)
        else
          local fallback = config.trigger or config.fallback or key
          return vim.api.nvim_replace_termcodes(fallback, true, false, true)
        end
      end, { expr = true, desc = "Navigate completion" })
    end

    -- Documentation scrolling
    map("i", "<C-f>", function()
      if completion_visible() then
        return vim.api.nvim_replace_termcodes("<C-f>", true, false, true)
      else
        return vim.api.nvim_replace_termcodes("<C-f>", true, false, true)
      end
    end, { expr = true, desc = "Scroll docs down" })

    map("i", "<C-d>", function()
      if completion_visible() then
        return vim.api.nvim_replace_termcodes("<C-b>", true, false, true)
      else
        return vim.api.nvim_replace_termcodes("<C-d>", true, false, true)
      end
    end, { expr = true, desc = "Scroll docs up" })

    -- Handle Escape
    map("i", "<Esc>", function()
      if vim.b[vim.api.nvim_get_current_buf()].nes_state ~= nil then
        local ok, nes = pcall(require, "copilot-lsp.nes")
        if ok then
          nes.clear()
        end
        return ""
      end

      if completion_visible() then
        user_navigated = false
        return vim.api.nvim_replace_termcodes("<C-c>", true, false, true)
      else
        return vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
      end
    end, { expr = true, desc = "Close completion or escape" })

    -- Reset navigation flag
    vim.api.nvim_create_autocmd("CompleteChanged", {
      callback = function()
        if vim.fn.pumvisible() == 0 then
          user_navigated = false
        end
      end
    })

    -- Completion CR handler with autopairs
    if npairs_ok then
      map("i", "<CR>", function()
        if completion_visible() then
          if user_navigated then
            user_navigated = false
            return vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
          else
            return vim.api.nvim_replace_termcodes("<C-n><C-y>", true, false, true)
          end
        else
          return npairs.autopairs_cr()
        end
      end, { expr = true, replace_keycodes = false, desc = "Accept completion or autopairs CR" })
    else
      map("i", "<CR>", function()
        if completion_visible() then
          return vim.api.nvim_replace_termcodes("<C-n><C-p><C-y>", true, false, true)
        else
          return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
        end
      end, { expr = true, desc = "Accept completion or newline" })
    end

    -- Set up autopairs integration
    if npairs_ok then
      local Rule = require('nvim-autopairs.rule')

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

    -- Auto-close preview window
    vim.api.nvim_create_autocmd({ "InsertLeave", "CompleteDone" }, {
      callback = function()
        pcall(vim.cmd, "pclose")
      end
    })

    -- Close completion menu when typing closing characters
    vim.api.nvim_create_autocmd("InsertCharPre", {
      callback = function()
        local char = vim.v.char
        local close_chars = { '>', ')', '}', ']', ';', ',', ' ', '\t' }
        if vim.tbl_contains(close_chars, char) and completion_visible() then
          vim.schedule(function()
            vim.fn.complete(1, {})
          end)
        end
      end
    })
  end,
}
