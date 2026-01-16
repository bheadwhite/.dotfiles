return {
  {
    type = "delve",
    name = "file",
    request = "launch",
    program = "${file}",
    outputMode = "remote",
  },
  {
    name = "launch attachments",
    type = "go",
    request = "launch",
    mode = "debug",
    program = "${workspaceFolder}/attachmentsctl",
    console = "integratedTerminal",
    outputMode = "remote",
    args = {
      "start",
    },
  },
  -- {
  --   name = "launch campaigns",
  --   type = "go",
  --   request = "launch",
  --   mode = "debug",
  --   program = "${workspaceFolder}/processorsctl",
  --   args = {
  --     "campaigns",
  --     "start",
  --   },
  -- },
  -- {
  --   name = "launch messages",
  --   type = "go",
  --   request = "launch",
  --   mode = "debug",
  --   program = "${workspaceFolder}/processorsctl",
  --   args = {
  --     "messages",
  --     "start",
  --   },
  -- },
  -- {
  --   name = "launch conversations",
  --   type = "go",
  --   request = "launch",
  --   mode = "debug",
  --   program = "${workspaceFolder}/processorsctl",
  --   args = {
  --     "conversations",
  --     "start",
  --   },
  -- },
  -- {
  --   name = "launch tasks",
  --   type = "go",
  --   request = "launch",
  --   mode = "debug",
  --   program = "${workspaceFolder}/processorsctl",
  --   args = {
  --     "tasks",
  --     "start",
  --   },
  -- },
  -- {
  --   name = "launch omniapi",
  --   type = "go",
  --   request = "launch",
  --   mode = "debug",
  --   program = "${workspaceFolder}/omnictl",
  --   args = {
  --     "api",
  --     "start",
  --   },
  -- },
}
