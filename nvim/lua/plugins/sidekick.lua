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
        events = { "ModeChanged i:n", "TextChanged", "User SidekickNesDone", "BufEnter", "WinEnter" },
      },
    },
    -- CLI configuration
    cli = {
      watch = true, -- Notify Neovim of file changes done by AI CLI tools
      mux = {
        backend = "zellij", -- or "tmux"
        enabled = true,
        create = "terminal", -- "terminal"|"window"|"split"
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
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle({ name = "cursor", focus = true })
      end,
      mode = { "n" },
      desc = "Toggle Cursor Agent",
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
      "<leader>ath",
      function()
        require("sidekick.cli").send({ msg = "{this}" })
      end,
      mode = { "x", "n" },
      desc = "Send This to CLI",
    },
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
    {
      "<leader>at",
      function()
        require("sidekick.cli").send({ msg = "Can you write tests for {this}?" })
      end,
      mode = { "n", "x" },
      desc = "Generate Tests",
    },
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
