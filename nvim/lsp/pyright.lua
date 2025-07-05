return {
  settings = {
    python = {
      venvPath = ".",
      pythonPath = "./.venv/bin/python",
      analysis = {
        extraPaths = { "." },
        typeCheckingMode = "off",
        diagnosticMode = "off",
      },
    },
  },
}
