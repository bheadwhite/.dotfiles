local function get_jest_test_name()
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for i = cursor_row, 1, -1 do
    local line = lines[i]:match("[\"'](.-)[\"']")
    if line then
      return line
    end
  end

  return nil
end

--- Gets a path to a package in the Mason registry.
--- Prefer this to `get_package`, since the package might not always be
--- available yet and trigger errors.
---@param pkg string
---@param path? string
local function get_pkg_path(pkg, path)
  pcall(require, "mason")
  local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
  path = path or ""
  local ret = root .. "/packages/" .. pkg .. "/" .. path
  return ret
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "williamboman/mason.nvim",
      "nvim-neotest/nvim-nio",
    },
    lazy = false,
    config = function()
      local dap = require("dap")

      require("dapui").setup()
      require("nvim-dap-virtual-text").setup({
        commented = true,
      })

      dap.adapters.chrome = {
        type = "executable",
        command = "node",
      }

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            get_pkg_path("js-debug-adapter", "/js-debug/src/dapDebugServer.js"),
            "${port}",
          },
        },
      }

      -- typescript
      for _, language in ipairs({ "typescriptreact", "javascriptreact", "typescript", "javascript" }) do
        require("dap").configurations[language] = {

          -- launch
          -- {
          --   type = "pwa-chrome",
          --   request = "launch",
          --   name = "Launch Chrome",
          --   url = "http://localhost:3000",
          --   webRoot = "${workspaceFolder}",
          -- },
          --
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            -- trace = true, -- include debugger info
            runtimeExecutable = "node",
            runtimeArgs = function()
              local test_name = get_jest_test_name()

              vim.print("Running Jest test: " .. (test_name or "all tests"))

              return {
                "./node_modules/jest/bin/jest.js",
                "--runInBand",
                test_name and "--testNamePattern" or nil,
                test_name,
              }
            end,
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
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
      -- dap.configurations.go = {}
      --
      -- local function load_vscode_go_configs()
      --   local ok, json = pcall(require, "dkjson")
      --   if not ok then
      --     -- vim.notify("Failed to load dkjson, unable to load vscode go configurations")
      --     return
      --   end
      --   local cwd = vim.fn.getcwd()
      --   local vscode_dir = cwd .. "/.vscode"
      --   local launch_file = vscode_dir .. "/launch.json"
      --   local uv = vim.loop
      --
      --   if uv.fs_stat(vscode_dir) and uv.fs_stat(launch_file) then
      --     local file = io.open(launch_file, "r")
      --     if file then
      --       local content = file:read("*a")
      --       file:close()
      --       local success, parsed = pcall(json.decode, content)
      --       if success and parsed.configurations then
      --         for _, config in ipairs(parsed.configurations) do
      --           if config.type == "go" then
      --             local configuration = {
      --               name = config.name or "VSCode Config",
      --               type = config.type,
      --               request = config.request,
      --               mode = config.mode or "debug",
      --               program = config.program or "${workspaceFolder}",
      --               args = config.args or {},
      --             }
      --
      --             if config.cwd then
      --               configuration.cwd = config.cwd
      --             end
      --
      --             table.insert(dap.configurations.go, configuration)
      --           end
      --         end
      --       else
      --         vim.notify("Failed to parse launch.json", vim.log.levels.ERROR)
      --       end
      --     end
      --   end
      -- end
      -- load_vscode_go_configs()
      require("dap-go").setup()

      local known_configs = require("bdub.dap_known_configurations")
      for _, config in ipairs(known_configs) do
        table.insert(dap.configurations.go, config)
      end

      vim.keymap.set("n", "<C-M-S-return>", "<cmd>lua require('dap').continue()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>b", "<cmd>lua require('dap').toggle_breakpoint()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>dc", "<cmd>lua require('dap').run_to_cursor()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>dr", "<cmd>lua require('dap').repl.toggle()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<C-M-S-.>", "<cmd>lua require('dap').step_over()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<C-M-S-i>", "<cmd>lua require('dap').step_into()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<C-M-S-,>", "<cmd>lua require('dap').step_out()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>du", "<cmd>lua require('dapui').toggle()<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "<C-M-S-m>", "<cmd>lua require('nvim-dap-virtual-text').toggle()<cr>", { noremap = true, silent = true })
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
  },
}
