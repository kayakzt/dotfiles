return {
  init_options = {
    settings = {
      exclude = { ".git", ".venv", ".vscode" },
      lineLength = 100,
      lint = {
        ignore = { "F401" }, -- suppress duplicate lint with pyright
      },
      logLevel = "info",
      organizeImports = true,
      showSyntaxErrors = false,
    },
  },
}
