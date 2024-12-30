return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    event = "VimEnter",
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

  -- UltiSnips
  {
    "SirVer/ultisnips",
    config = function()
      -- Set UltiSnips triggers
      -- vim.g.UltiSnipsExpandTrigger = "<C-e>"
      -- vim.g.UltiSnipsJumpForwardTrigger = "<C-j>"
      -- vim.g.UltiSnipsJumpBackwardTrigger = "<C-k>"

      vim.g.UltiSnipsEditSplit = "vertical"
      vim.g.UltiSnipsSnippetDirectories = { os.getenv("HOME") .. "/.config/nvim/UltiSnips" }
      vim.g.ultisnips_python_style = "google"
    end,
  },
  {
    "honza/vim-snippets",
    event = "InsertEnter",
    dependencies = { "SirVer/ultisnips" },
  },

  -- Completion Plugins
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-git",
      "quangnguyen30192/cmp-nvim-ultisnips",
    },
    config = function()
      local cmp = require("cmp")
      local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body) -- for ultisnips users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping(function(fallback)
            cmp_ultisnips_mappings.expand_or_jump_forwards(fallback)
          end, {
            "i",
            "s", --[[ "c" (to enable the mapping in command mode) ]]
          }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "buffer" },
          { name = "git" },
          { name = "path" },
          { name = "calc" },
          { name = "ultisnips" },
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
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "nvimdev/lspsaga.nvim",
    event = "VimEnter",
    dependencies = { "nvim-treesitter", "nvim-web-devicons" },
    config = function()
      require("lspsaga").setup({
        symbol_in_winbar = {
          enable = false,
          show_server_name = false,
          show_file = false,
        },
        finder = { enable = false },
        code_action = { extend_gitsigns = true },
        lightbulb = { enable = false },
      })
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
      vim.keymap.set("n", "[lsp]n", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
      vim.keymap.set("n", "[lsp]p", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
      vim.keymap.set("n", "[lsp]d", "<cmd>Lspsaga show_buf_diagnostics<CR>", opts)
      vim.keymap.set("n", "[lsp]wd", "<cmd>Lspsaga show_workspace_diagnostics<CR>", opts)
      vim.keymap.set("n", "gh", "<cmd>Lspsaga hover_doc<CR>", opts)
      vim.keymap.set("n", "[lsp]a", "<cmd>Lspsaga code_action<CR>", opts)
      vim.keymap.set("n", "[lsp]r", "<cmd>Lspsaga rename<CR>", opts)
      vim.keymap.set("n", "[lsp]F", "<cmd>Lspsaga finder<CR>", opts)
    end,
  },
}
