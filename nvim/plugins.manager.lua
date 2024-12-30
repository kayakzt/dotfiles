return {
  -- Mason Integration
  {
    "williamboman/mason.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "BufEnter",
    dependencies = { "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        "bashls",
        "clangd",
        "dockerls",
        "gopls",
        "jsonls",
        "ts_ls",
        "pyright",
        "rust_analyzer",
        "taplo",
        "typos_lsp",
      }

      mason.setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      mason_lspconfig.setup({
        ensure_installed = servers,
      })

      require("mason-lspconfig").setup_handlers({
        function(server_name) -- default handler (optional)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
          lspconfig.pyright.setup({
            settings = {
              python = {
                venvPath = ".",
                pythonPath = "./.venv/bin/python",
                analysis = {
                  extraPaths = { "." },
                },
              },
            },
          })
          lspconfig.typos_lsp.setup({
            init_options = {
              diagnosticSeverity = "Information", -- change warning level
            },
          })
        end,
      })
    end,
  },

  {
    "nvim-lua/plenary.nvim",
  },

  {
    "MunifTanjim/nui.nvim",
  },

  {
    "jay-babu/mason-null-ls.nvim",
    event = "BufEnter",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-null-ls").setup({
        ensure_installed = {
          "biome",
          "black",
          "goimports",
          "impl",
          "gomodifytags",
          "stylua",
          "isort",
          "markdownlint",
          "prettier",
          "textlint",
          "shellcheck",
        },
      })
    end,
  },

  -- None-ls
  {
    "nvimtools/none-ls.nvim",
    event = "BufEnter",
    dependencies = { "nvim-lua/plenary.nvim", "jay-babu/mason-null-ls.nvim" },
    config = function()
      local null_ls = require("null-ls")
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

      local disabled_format_clients = { "lua_ls", "volar", "tsserver" }

      local on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                async = false,
                filter = function(c)
                  -- return not vim.tbl_contains(disabled_format_clients, c.name)
                  return c.name == "null-ls"
                end,
                timeout_ms = 1000,
              })
            end,
          })
        end
      end

      null_ls.setup({
        on_attach = on_attach,
        sources = {
          null_ls.builtins.completion.spell.with({
            filetypes = { "text", "markdown", "tex", "latex" },
          }),
          null_ls.builtins.code_actions.gitsigns.with({
            config = {
              filter_actions = function(title)
                return title:lower():match("blame") == nil -- filter out blame actions
              end,
            },
          }),
          null_ls.builtins.code_actions.gomodifytags,
          null_ls.builtins.code_actions.impl,
          -- null_ls.builtins.diagnostics.editorconfig_checker,
          null_ls.builtins.diagnostics.markdownlint,
          null_ls.builtins.diagnostics.textlint.with({
            condition = function(utils)
              return utils.root_has_file({ ".textlintrc" })
            end,
          }),
          null_ls.builtins.diagnostics.vint,
          null_ls.builtins.diagnostics.zsh,
          null_ls.builtins.formatting.biome,
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.gofmt,
          null_ls.builtins.formatting.goimports,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.markdownlint,
          null_ls.builtins.formatting.prettier.with({
            filetypes = { "vue", "css", "scss", "less", "html", "yaml", "graphql", "handlebars" },
          }),
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.textlint.with({
            condition = function(utils)
              return utils.root_has_file({ ".textlintrc" })
            end,
          }),
          null_ls.builtins.hover.dictionary,
        },
      })
    end,
  },
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    version = "v0.*",
    event = "BufEnter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "cmake",
          "comment",
          "cpp",
          "css",
          "dart",
          "diff",
          "dockerfile",
          "git_rebase",
          "go",
          "html",
          "javascript",
          "jq",
          "json",
          "jsonc",
          "latex",
          "lua",
          "make",
          "markdown",
          "markdown_inline",
          "python",
          "rust",
          "scss",
          "typescript",
          "toml",
          "vim",
          "vue",
          "yaml",
        },
        sync_install = false,
        auto_install = false,
        highlight = {
          enable = true,
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
