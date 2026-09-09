-- Prompt for a free-text question and send it to the Claude CLI along with
-- whatever you're looking at: {this} is the visual selection in visual mode,
-- or the function/line under the cursor in normal mode.
local function ask_claude()
  local cli = require("sidekick.cli")
  -- Pre-warm the Claude session while you type. On a cold start, sidekick's
  -- send() pastes the text and hits Enter immediately, but the Claude TUI is
  -- still booting so the Enter gets swallowed -- the text lands in the input
  -- box but is never submitted. Starting the session here (without stealing
  -- focus) lets it finish booting during the few seconds you spend typing, so
  -- the submit below lands on a ready prompt.
  cli.show({ name = "claude", focus = false })
  vim.ui.input({ prompt = "Ask Claude: " }, function(q)
    if not q or q == "" then
      return
    end
    cli.send({
      msg = "{this}\n\n" .. q,
      filter = { name = "claude" },
      submit = true,
    })
  end)
end

-- caps+space. Resolved at spec-load time because lazy.nvim reads `keys` eagerly.
local ok_bdub, bdub = pcall(require, "bdub")
local hyper_space = ok_bdub and bdub.hyper_space_key or nil

return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    -- Next Edit Suggestions (NES) configuration
    nes = {
      enabled = true,
      diff = {
        inline = "words", -- Enable inline word-level diffs
      },
      trigger = {
        events = { "ModeChanged i:n", "TextChanged", "User SidekickNesDone" },
      },
    },
    -- CLI configuration
    cli = {
      watch = true, -- Notify Neovim of file changes done by AI CLI tools
      mux = {
        backend = "tmux",
        enabled = true,
        create = "terminal",
      },
      win = {
        layout = "right", -- "float"|"left"|"bottom"|"top"|"right"
        float = {
          width = 0.9,
          height = 0.9,
        },
        split = {
          width = 80,
          height = 20,
        },
      },
      -- Configure cursor-agent tool
      tools = {
        cursor = {
          cmd = { "cursor-agent" },
          -- cursor-agent manages its own sessions
          -- If session exists, cursor-agent will attach automatically
          -- The mux backend (zellij) will create a terminal session for it
        },
      },
      -- Custom prompts for AI interactions
      prompts = {
        -- Built-in prompts (can be overridden)
        explain = "Explain {this}",
        fix = "Can you fix {this}?",
        optimize = "How can {this} be optimized?",
        tests = "Can you write tests for {this}?",
        review = "Can you review {file} for any issues or improvements?",
        document = "Add documentation to {function|line}",
        diagnostics = "Can you help me fix the diagnostics in {file}?\n{diagnostics}",
        -- Custom prompts
        refactor = "Please refactor {this} to be more maintainable and follow best practices",
        security = "Review {this} for security vulnerabilities and suggest improvements",
        performance = "Analyze {this} for performance issues and suggest optimizations",
        style = "Review {this} for code style issues and suggest improvements to match the project's style guide",
        debug = "Help me debug {this}. What could be causing the issue?",
        simplify = "Simplify {this} while maintaining the same functionality",
        improve = "How can I improve {this} code?",
      },
    },
    -- Copilot status tracking
    copilot = {
      status = {
        enabled = true,
        level = vim.log.levels.WARN,
      },
    },
  },
  keys = {
    -- Free-text question about whatever you're looking at.
    -- Normal mode: {this} is the function/line under the cursor.
    -- Visual mode: {this} is the selection.
    {
      "<leader>aa",
      ask_claude,
      mode = { "n", "x" },
      desc = "Ask Claude about this",
    },
    {
      hyper_space or "<Nop>",
      ask_claude,
      mode = { "n", "x" },
      desc = "Ask Claude about this (caps+space)",
    },
    -- Toggle the Claude split without sending anything.
    {
      "<leader>at",
      function()
        require("sidekick.cli").toggle({ name = "claude", focus = true })
      end,
      mode = { "n" },
      desc = "Toggle Claude CLI",
    },
    {
      "<leader>aR",
      function()
        local cli = require("sidekick.cli")
        cli.close({ name = "claude" })
        vim.defer_fn(function()
          cli.toggle({ name = "claude", focus = true })
        end, 200)
      end,
      mode = { "n" },
      desc = "Restart Claude CLI",
    },
    {
      "<c-m-u>",
      function()
        require("sidekick.cli").send({ msg = "{this}" })
      end,
      mode = { "x", "n", "i" },
      desc = "Send This to CLI",
    },
    {
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n" },
      desc = "Select Prompt",
    },
    -- Send content to CLI
    {
      "<leader>af",
      function()
        require("sidekick.cli").send({ msg = "{file}" })
      end,
      desc = "Send File to CLI",
    },
    {
      "<leader>av",
      function()
        require("sidekick.cli").send({ msg = "{selection}" })
      end,
      mode = { "x" },
      desc = "Send Visual Selection to CLI",
    },
    {
      "<leader>ae",
      function()
        require("sidekick.cli").send({ msg = "Explain {this}" })
      end,
      mode = { "n", "x" },
      desc = "Explain Code",
    },
    {
      "<leader>ar",
      function()
        require("sidekick.cli").send({ msg = "Please refactor {this} to be more maintainable and follow best practices" })
      end,
      mode = { "n", "x" },
      desc = "Refactor Code",
    },
    {
      "<leader>ad",
      function()
        require("sidekick.cli").send({ msg = "Help me debug {this}. What could be causing the issue?" })
      end,
      mode = { "n", "x" },
      desc = "Debug Code",
    },
    -- {
    --   "<leader>at",
    --   function()
    --     require("sidekick.cli").send({ msg = "Can you write tests for {this}?" })
    --   end,
    --   mode = { "n", "x" },
    --   desc = "Generate Tests",
    -- },
    {
      "<leader>ai",
      function()
        require("sidekick.cli").send({ msg = "How can I improve {this} code?" })
      end,
      mode = { "n", "x" },
      desc = "Improve Code",
    },
  },
}
