return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "leoluz/nvim-dap-go",
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
    "williamboman/mason.nvim",
  },
  lazy = false,
  config = function()
    local dap = require("dap")
    local ui = require("dapui")

    require("dapui").setup()
    require("nvim-dap-virtual-text").setup()

    ---------- end -----------

    dap.adapters.chrome = {
      type = "executable",
      command = "node",
    }

    for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
      require("dap").configurations[language] = {
        -- launch
        -- {
        --   type = "pwa-chrome",
        --   request = "launch",
        --   name = "Launch Chrome",
        --   url = "http://localhost:3000",
        --   webRoot = "${workspaceFolder}",
        -- },
        {
          type = "pwa-chrome",
          request = "attach",
          name = "Attach Chrome",
          port = 9222,
          webRoot = "${workspaceFolder}",
          runtimeExecutable = "canary",
        },
      }
    end

    --- go

    dap.configurations.go = {
      {
        name = "launch attachments",
        type = "go",
        request = "launch",
        mode = "debug",
        program = "${workspaceFolder}/attachmentsctl/main.go",
        args = {
          "start",
        },
      },
    }

    require("dap-go").setup()

    vim.keymap.set("n", "<leader>dd", "<cmd>lua require('dap').continue()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>b", "<cmd>lua require('dap').toggle_breakpoint()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>dc", "<cmd>lua require('dap').run_to_cursor()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>dr", "<cmd>lua require('dap').repl.toggle()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-M-S-.>", "<cmd>lua require('dap').step_over()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-M-S-i>", "<cmd>lua require('dap').step_into()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-M-S-,>", "<cmd>lua require('dap').step_out()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-M-S-h>", "<cmd>lua require('dap.ui.widgets').hover()<cr>", { noremap = true, silent = true })
    vim.keymap.set(
      "n",
      "<leader>df",
      "<cmd>lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').frames)<cr>",
      { noremap = true, silent = true }
    )
    vim.keymap.set(
      "n",
      "<leader>ds",
      "<cmd>lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').scopes)<cr>",
      { noremap = true, silent = true }
    )

    vim.keymap.set("n", "<leader>?", function()
      require("dapui").eval(nil, { enter = true })
    end)

    dap.listeners.before.attach.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      ui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      ui.close()
    end
  end,
}
