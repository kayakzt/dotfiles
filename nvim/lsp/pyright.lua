return {
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      venvPath = ".",
      pythonPath = "./.venv/bin/python",
      analysis = {
        exclude = { ".git", ".venv", ".vscode" },
        extraPaths = { "." },
        typeCheckingMode = "basic",
        -- diagnosticMode = "workspace",
        diagnosticMode = "openFilesOnly",
      },
    },
  },
}
