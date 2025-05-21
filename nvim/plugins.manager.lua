return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    version = "v1.*",
    config = function()
      vim.diagnostic.config({ severity_sort = true })
      vim.keymap.set("n", "<C-k>", "[lsp]", { noremap = true, silent = true, remap = true })

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      -- vim.keymap.set('n', '[lsp]D', vim.diagnostic.open_float)
      -- vim.keymap.set('n', '[lsp]n', vim.diagnostic.goto_next)
      -- vim.keymap.set('n', '[lsp]p', vim.diagnostic.goto_prev)
      -- vim.keymap.set('n', '[lsp]d', vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts)
          -- vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "[lsp]D", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "[lsp]s", vim.lsp.buf.signature_help, opts)
          -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          -- vim.keymap.set('n', '<space>wl', function()
          --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          -- end, opts)
          vim.keymap.set("n", "[lsp]t", vim.lsp.buf.type_definition, opts)
          -- vim.keymap.set('n', '[lsp]r', vim.lsp.buf.rename, opts)
          -- vim.keymap.set({ 'n', 'v' }, '[lsp]a', vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "[lsp]R", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "[lsp]f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })
    end,
  },

  -- {
  --   "SirVer/ultisnips",
  --   event = "InsertEnter",
  --   config = function()
  --     -- Set UltiSnips triggers
  --     vim.g.UltiSnipsExpandTrigger = "<C-e>"
  --     vim.g.UltiSnipsJumpForwardTrigger = "<C-j>"
  --     vim.g.UltiSnipsJumpBackwardTrigger = "<C-k>"
  --
  --     vim.g.UltiSnipsEditSplit = "vertical"
  --     vim.g.UltiSnipsSnippetDirectories = { os.getenv("HOME") .. "/.config/nvim/UltiSnips" }
  --     vim.g.ultisnips_python_style = "google"
  --   end,
  -- },
  -- {
  --   "honza/vim-snippets",
  --   dependencies = { "SirVer/ultisnips" },
  -- },
  {
    "hrsh7th/vim-vsnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      vim.g.vsnip_snippet_dir = vim.fn.expand(os.getenv("HOME") .. "/.config/nvim/vsnip")
      vim.keymap.set("i", "<C-e>", function()
        return vim.fn["vsnip#available"](1) == 1 and "<Plug>(vsnip-expand-or-jump)" or "<C-e>"
      end, { expr = true })

      vim.keymap.set("s", "<C-e>", function()
        return vim.fn["vsnip#available"](1) == 1 and "<Plug>(vsnip-expand-or-jump)" or "<C-e>"
      end, { expr = true })
    end,
  },

  -- Completion Plugins
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-git",
      -- "quangnguyen30192/cmp-nvim-ultisnips",
      "hrsh7th/vim-vsnip",
      "hrsh7th/cmp-vsnip",
    },
    config = function()
      local cmp = require("cmp")
      -- local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- for ultisnips users.
            -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          -- ["<C-e>"] = cmp.mapping(function(fallback)
          --   cmp_ultisnips_mappings.expand_or_jump_forwards(fallback)
          -- end, {
          --   "i",
          --   "s", --[[ "c" (to enable the mapping in command mode) ]]
          -- }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "buffer" },
          { name = "git" },
          { name = "path" },
          { name = "calc" },
          -- { name = "ultisnips" },
          { name = "vsnip" },
        }),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
          { name = "path" },
        },
        {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })

      require("cmp_git").setup()
    end,
  },

  -- Mason & LSP Integration
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "mason-org/mason-lspconfig.nvim",
    version = "v1.*",
    -- event = "VimEnter",
    dependencies = {"hrsh7th/cmp-nvim-lsp" },
  },
  {
    "mason-org/mason.nvim",
    -- event = "VimEnter",
    version = "v1.*",
    dependencies = { "mason-org/mason-lspconfig.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
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
        "lua_ls",
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

      -- mason_lspconfig.setup({
      --   ensure_installed = servers,
      --   automatic_enable = true,
      -- })
      --
      -- for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
      --   -- Specific servers configurations
      --   if server  == 'pyright' then
      --     vim.lsp.config(server, {
      --       capabilities = capabilities,
      --       settings = {
      --         ['pyright'] = {
      --           python = {
      --             venvPath = ".",
      --             pythonPath = "./.venv/bin/python",
      --             analysis = {
      --               extraPaths = { "." },
      --             },
      --           },
      --         },
      --       },
      --     })
      --   elseif server == 'typos_lsp' then
      --     vim.lsp.config(server, {
      --       capabilities = capabilities,
      --       settings = {
      --         ['typos_lsp'] = {
      --           init_options = {
      --             diagnosticSeverity = "Information",
      --           },
      --         },
      --       },
      --     })
      --   elseif server == 'lua_ls' then
      --     vim.lsp.config(server, {
      --       capabilities = capabilities,
      --       on_init = function(client)
      --         if client.workspace_folders then
      --           local path = client.workspace_folders[1].name
      --           if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
      --             return
      --           end
      --         end
      --
      --         client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      --           runtime = {
      --             -- Tell the language server which version of Lua you're using
      --             -- (most likely LuaJIT in the case of Neovim)
      --             version = "LuaJIT",
      --           },
      --           -- Make the server aware of Neovim runtime files
      --           workspace = {
      --             checkThirdParty = false,
      --             library = {
      --               vim.env.VIMRUNTIME,
      --               -- Depending on the usage, you might want to add additional paths here.
      --               -- "${3rd}/luv/library"
      --               -- "${3rd}/busted/library",
      --             },
      --             -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
      --             -- library = vim.api.nvim_get_runtime_file("", true)
      --           },
      --         })
      --       end,
      --     })
      --   else
      --     vim.lsp.config(server, {
      --       capabilities = capabilities,
      --     })
      --   end
      -- end


      -- NOTE: Below Block must be removed if you use v2 series mason
      mason_lspconfig.setup_handlers({
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
          lspconfig.lua_ls.setup({
            on_init = function(client)
              if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
                  return
                end
              end

              client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                runtime = {
                  -- Tell the language server which version of Lua you're using
                  -- (most likely LuaJIT in the case of Neovim)
                  version = "LuaJIT",
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                  checkThirdParty = false,
                  library = {
                    vim.env.VIMRUNTIME,
                    -- Depending on the usage, you might want to add additional paths here.
                    -- "${3rd}/luv/library"
                    -- "${3rd}/busted/library",
                  },
                  -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
                  -- library = vim.api.nvim_get_runtime_file("", true)
                },
              })
            end,
            settings = {
              Lua = {},
            },
          })
        end,
      })
    end,
  },

  {
    "jay-babu/mason-null-ls.nvim",
    event = "BufReadPre",
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

  {
    "nvimtools/none-ls.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim", "jay-babu/mason-null-ls.nvim" },
    config = function()
      local null_ls = require("null-ls")
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

      -- local disabled_format_clients = { "lua_ls", "volar", "tsserver" }

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
          null_ls.builtins.formatting.stylua.with({
            filetypes = { "lua" },
          }),
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
