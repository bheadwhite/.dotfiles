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

    require("dapui").setup()
    require("nvim-dap-virtual-text").setup({
      commented = true,
    })

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
    local function load_vscode_go_configs()
      local ok, json = pcall(require, "dkjson")
      if not ok then
        -- vim.notify("Failed to load dkjson, unable to load vscode go configurations")
        return
      end
      local cwd = vim.fn.getcwd()
      local vscode_dir = cwd .. "/.vscode"
      local launch_file = vscode_dir .. "/launch.json"
      local uv = vim.loop

      if uv.fs_stat(vscode_dir) and uv.fs_stat(launch_file) then
        local file = io.open(launch_file, "r")
        if file then
          local content = file:read("*a")
          file:close()
          local success, parsed = pcall(json.decode, content)
          if success and parsed.configurations then
            for _, config in ipairs(parsed.configurations) do
              if config.type == "go" then
                local configuration = {
                  name = config.name or "VSCode Config",
                  type = config.type,
                  request = config.request,
                  mode = config.mode or "debug",
                  program = config.program or "${workspaceFolder}",
                  args = config.args or {},
                }

                if config.cwd then
                  configuration.cwd = config.cwd
                end

                table.insert(dap.configurations.go, configuration)
              end
            end
          else
            vim.notify("Failed to parse launch.json", vim.log.levels.ERROR)
          end
        end
      end
    end

    dap.configurations.go = {
      {
        name = "launch attachments",
        type = "go",
        request = "launch",
        mode = "debug",
        program = "${workspaceFolder}/attachmentsctl",
        args = {
          "start",
        },
      },
      {
        name = "launch campaigns",
        type = "go",
        request = "launch",
        mode = "debug",
        program = "${workspaceFolder}/processorsctl",
        args = {
          "campaigns",
          "start",
        },
      },
      {
        name = "launch messages",
        type = "go",
        request = "launch",
        mode = "debug",
        program = "${workspaceFolder}/processorsctl",
        args = {
          "messages",
          "start",
        },
      },
      {
        name = "launch conversations",
        type = "go",
        request = "launch",
        mode = "debug",
        program = "${workspaceFolder}/processorsctl",
        args = {
          "conversations",
          "start",
        },
      },
      {
        name = "launch tasks",
        type = "go",
        request = "launch",
        mode = "debug",
        program = "${workspaceFolder}/processorsctl",
        args = {
          "tasks",
          "start",
        },
      },
      {
        name = "launch omniapi",
        type = "go",
        request = "launch",
        mode = "debug",
        program = "${workspaceFolder}/omnictl",
        args = {
          "api",
          "start",
        },
      },
    }

    load_vscode_go_configs()

    require("dap-go").setup()

    vim.keymap.set("n", "<leader>D", "<cmd>lua require('dap').continue()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>b", "<cmd>lua require('dap').toggle_breakpoint()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>dc", "<cmd>lua require('dap').run_to_cursor()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>dr", "<cmd>lua require('dap').repl.toggle()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-M-S-.>", "<cmd>lua require('dap').step_over()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-M-S-i>", "<cmd>lua require('dap').step_into()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-M-S-,>", "<cmd>lua require('dap').step_out()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>du", "<cmd>lua require('dapui').toggle()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>dv", "<cmd>lua require('nvim-dap-virtual-text').refresh()<cr>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-M-S-h>", function()
      require("dapui").eval(nil, { enter = true })
    end, { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>db", "<cmd>Telescope dap list_breakpoints<cr>", { noremap = true, silent = true })
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
  end,
}
