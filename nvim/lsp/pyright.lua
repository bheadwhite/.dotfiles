return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/pyright" },
  filetypes = { "python" },
  root_markers = { "pyrightconfig.json", ".git/" }, -- Look for pyrightconfig.json or .git directory
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "standard", --basic, standard, strict
        diagnosticSeverityOverrides = {
          -- reportArgumentType = "information",
          -- reportUnusedFunction = "warning",
          -- reportUnusedVariable = "information",
          -- reportUnusedExpression = "information",
          -- reportAssignmentType = "information",
          -- reportUnknownVariableType = false,
          -- reportMissingTypeStubs = false,
          -- reportUnknownMemberType = "warning",
          -- reportUnknownParameterType = false,
          -- reportMissingTypeArgument = false,
          -- reportUnknownArgumentType = false,
          -- reportAttributeAccessIssue = "warning",
          -- reportReturnType = "information",
          -- reportIndexIssue = "information",
          -- reportOperatorIssue = "information",
          -- reportGeneralTypeIssues = "information",
          -- reportOptionalIterable = "information",
        },
      },
      venvPath = "/Users/brent.whitehead/.python_env/envs/python-3-11",
    },
  },
}
