-- Module-level variable to track navigation state
local user_navigated = false

return {
  name = "native-completion",
  cond = not vim.g.vscode,
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

    -- Handle Ctrl-V for Copilot and completion
    local function handle_ctrl_v()
      local copilot_ok, copilot = pcall(require, "copilot.suggestion")
      if copilot_ok and copilot.is_visible() then
        copilot.accept()
        return ""
      end

      if completion_visible() then
        -- Use the existing user_navigated flag to determine behavior
        if user_navigated then
          -- User has navigated, so something is selected - just accept it
          return vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
        else
          -- No navigation yet, select first item and accept
          return vim.api.nvim_replace_termcodes("<C-n><C-y>", true, false, true)
        end
      end
    end

    -- Set up autopairs integration with navigation tracking
    local npairs_ok, npairs = pcall(require, "nvim-autopairs")

    -- Main completion keymaps
    -- map("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger completion" })
    -- map("i", "<M-Space>", "<C-x><C-o>", { desc = "Trigger completion" })
    map("i", "<C-e>", "<C-e>", { desc = "Close completion menu" })
    map("i", "<C-v>", handle_ctrl_v, { expr = true, desc = "Accept Copilot or trigger completion" })

    map("n", "<C-v>", function()
      local sidekick_ok, sidekick = pcall(require, "sidekick.nes")
      if not sidekick_ok then
        vim.notify("sidekick.nes plugin not available", vim.log.levels.WARN)
        return
      end

      if not sidekick.enabled then
        sidekick.enable()
        return
      end

      if sidekick.have() then
        sidekick.apply()
      else
        sidekick.update()
      end
    end)

    -- Close completion menu when typing closing brackets
    local close_brackets = { ">", ")", "}", "]" }
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

    -- Handle arrow keys separately to avoid termcode issues
    map("i", "<Down>", function()
      if completion_visible() then
        user_navigated = true
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", true)
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, false, true), "n", true)
      end
    end, { desc = "Navigate completion or move down" })

    map("i", "<Up>", function()
      if completion_visible() then
        user_navigated = true
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-p>", true, false, true), "n", true)
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, false, true), "n", true)
      end
    end, { desc = "Navigate completion or move up" })

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
      -- if vim.b[vim.api.nvim_get_current_buf()].nes_state ~= nil then
      --   local ok, nes = pcall(require, "copilot-lsp.nes")
      --   if ok then
      --     nes.clear()
      --   end
      --   -- Still need to send escape to actually exit insert mode
      --   return vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
      -- end

      if completion_visible() then
        user_navigated = false
        return vim.api.nvim_replace_termcodes("<C-c>", true, false, true)
      else
        return vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
      end
    end, { expr = true, desc = "Close completion or escape" })

    -- Reset navigation flag only when completion menu closes
    vim.api.nvim_create_autocmd({ "InsertLeave", "CompleteDone" }, {
      callback = function()
        user_navigated = false
      end,
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
      local Rule = require("nvim-autopairs.rule")

      npairs.add_rules({
        Rule(" ", " "):with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({ "()", "[]", "{}" }, pair)
        end),
        Rule("( ", " )")
          :with_pair(function()
            return false
          end)
          :with_move(function(opts)
            return opts.prev_char:match(".%)") ~= nil
          end)
          :use_key(")"),
        Rule("{ ", " }")
          :with_pair(function()
            return false
          end)
          :with_move(function(opts)
            return opts.prev_char:match(".%}") ~= nil
          end)
          :use_key("}"),
        Rule("[ ", " ]")
          :with_pair(function()
            return false
          end)
          :with_move(function(opts)
            return opts.prev_char:match(".%]") ~= nil
          end)
          :use_key("]"),
      })
    end

    -- Auto-close preview window
    vim.api.nvim_create_autocmd({ "InsertLeave", "CompleteDone" }, {
      callback = function()
        pcall(vim.cmd, "pclose")
      end,
    })

    -- Close completion menu when typing closing characters
    vim.api.nvim_create_autocmd("InsertCharPre", {
      callback = function()
        local char = vim.v.char
        local close_chars = { ">", ")", "}", "]", ";", ",", " ", "\t" }
        if vim.tbl_contains(close_chars, char) and completion_visible() then
          vim.schedule(function()
            vim.fn.complete(1, {})
          end)
        end
      end,
    })

    local ok_bdub, bdub = pcall(require, "bdub")
    if ok_bdub and type(bdub.hyper_space_key) == "string" and bdub.hyper_space_key ~= "" then
      pcall(vim.keymap.del, "i", bdub.hyper_space_key)

      map("i", bdub.hyper_space_key, function()
        -- Check for Copilot suggestions first
        local copilot_ok, copilot = pcall(require, "copilot.suggestion")
        if copilot_ok then
          -- Cycle to next Copilot suggestion
          copilot.next()
          return ""
        end
      end, { expr = true, desc = "Trigger completion or next Copilot suggestion (bdub hyper space)" })
    end
  end,
}
