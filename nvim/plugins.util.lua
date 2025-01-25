return {
  {
    "tpope/vim-fugitive",
    event = "VimEnter",
    config = function()
      vim.keymap.set("n", "<Leader>g", "[git]", { noremap = true, silent = true, remap = true })
      vim.keymap.set("n", "[git]s", ":Git status<CR><C-w>T", { noremap = true, silent = true })
      vim.keymap.set("n", "[git]a", ":Git write<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[git]c", ":Git commit<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[git]b", ":Git blame<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[git]d", ":Git diff<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[git]m", ":Git merge<CR>", { noremap = true, silent = true })
    end,
  },
  {
    "rhysd/git-messenger.vim",
    event = "BufReadPost",
    config = function()
      vim.g.git_messenger_no_default_mappings = true
      vim.api.nvim_set_keymap("n", "[git]gm", ":GitMessenger<CR>", { noremap = true, silent = true })
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-web-devicons" },
    event = "BufReadPost",
    config = function()
      require("diffview").setup({ use_icons = false })
      vim.api.nvim_set_keymap("n", "[git]d", ":DiffviewOpen<CR>", { noremap = true, silent = true })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VimEnter",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          -- Navigation
          map("n", "]h", function()
            if vim.wo.diff then
              return "]h"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })
          map("n", "[h", function()
            if vim.wo.diff then
              return "[h"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })
          -- Actions
          map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
          map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
          map("n", "<leader>hS", gs.stage_buffer)
          map("n", "<leader>hu", gs.undo_stage_hunk)
          map("n", "<leader>hR", gs.reset_buffer)
          map("n", "<leader>hp", gs.preview_hunk)
          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end)
          map("n", "<leader>hd", gs.diffthis)
          map("n", "<leader>hD", function()
            gs.diffthis("~")
          end)
          map("n", "<leader>hw", ":Gitsigns toggle_word_diff<CR>")
          map("n", "<leader>ht", gs.toggle_deleted)
        end,
      })
    end,
  },
  {
    "rlane/pounce.nvim",
    event = "BufReadPost",
    config = function()
      require("pounce").setup({
        accept_keys = "JFKDLSAHGNUVRBYTMICEOXWPQZ",
        accept_best_key = "<enter>",
        multi_window = true,
        debug = false,
      })
      vim.keymap.set({ "n", "v", "o" }, "<S-m>", "[motion]", { noremap = true, silent = true, remap = true })
      vim.api.nvim_set_keymap("n", "[motion]", "<cmd>Pounce<CR>", { noremap = true })
      vim.api.nvim_set_keymap("v", "[motion]", "<cmd>Pounce<CR>", { noremap = true })
      vim.api.nvim_set_keymap("o", "[motion]", "<cmd>Pounce<CR>", { noremap = true })
    end,
  },
  {
    "thinca/vim-quickrun",
    event = "VimEnter",
    config = function()
      vim.g.quickrun_config = vim.g.quickrun_config or {}
      vim.g.quickrun_config._ = {
        runner = "vimproc",
        ["outputter/buffer/split"] = ":botright 8sp",
        outputter = "error",
        ["outputter/error/success"] = "buffer",
        ["outputter/error/error"] = "quickfix",
        ["outputter/buffer/close_on_empty"] = 1,
      }
      vim.g.quickrun_config.rust = { exec = "cargo run" }
      vim.g.quickrun_config.go = { exec = "go run ." }
      vim.g.quickrun_no_default_key_mappings = 1
      vim.api.nvim_set_keymap("n", "<Leader>r", ":cclose<CR>:write<CR>:QuickRun<CR>", { noremap = true })
      vim.api.nvim_set_keymap("x", "<Leader>r", ":<C-U>cclose<CR>:write<CR>gv:QuickRun -mode v<CR>", { noremap = true })
    end,
  },
  -- {
  --   "Shougo/context_filetype.vim",
  -- },
  -- {
  --   "osyo-manga/vim-precious",
  --   event = "BufEnter",
  --   dependencies = { "Shougo/context_filetype.vim" },
  -- },
  {
    "tpope/vim-surround",
    event = "BufReadPost",
  },

  {
    "bronson/vim-trailing-whitespace",
    event = "VimEnter",
    config = function()
      vim.g.extra_whitespace_ignored_filetypes = { "help", "diff", "TelescopePrompt", "Telescope" }
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function()
          vim.cmd("FixWhitespace")
        end,
      })
    end,
  },

  {
    "h1mesuke/vim-alignta",
    event = "BufEnter",
    cmd = "Alignta",
  },

  {
    "mattn/webapi-vim",
  },

  {
    "mattn/gist-vim",
    event = "BufEnter",
    cmd = "Gist",
    dependencies = { "mattn/webapi-vim" },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VimEnter",
    config = function()
      vim.opt.listchars:append("space:⋅")
      vim.opt.listchars:append("eol:↴")
      require("ibl").setup({
        scope = {
          show_start = false,
          show_end = false,
        },
      })
    end,
  },

  -- Smart character input
  {
    "kana/vim-smartchr",
    event = "InsertCharPre",
    config = function()
      vim.api.nvim_set_keymap("i", "=", "smartchr#loop('=', ' = ', ' == ', ' === ')", { expr = true, noremap = true })
    end,
  },

  -- Commenting plugin
  {
    "numToStr/Comment.nvim",
    event = "BufReadPre",
    config = function()
      require("Comment").setup({
        mappings = {
          basic = true,
          extra = true,
        },
      })
    end,
  },

  -- Binary file support
  {
    "Shougo/vinarise.vim",
    event = "VimEnter",
    cmd = "Vinarise",
    config = function()
      vim.g.vinarise_enable_auto_detect = 1
    end,
  },

  -- Open URLs in a browser
  {
    "tyru/open-browser.vim",
    event = "BufEnter",
    keys = { "<Plug>(openbrowser-smart-search)" },
    config = function()
      vim.api.nvim_set_keymap("n", "gs", "<Plug>(openbrowser-smart-search)", {})
      vim.api.nvim_set_keymap("v", "gs", "<Plug>(openbrowser-smart-search)", {})
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    event = "BufReadPost",
    ft = { "markdown", "pandoc.markdown", "rmd" },
    build = "cd app && npx --yes yarn install",
  },

  -- Table mode for Markdown
  {
    "dhruvasagar/vim-table-mode",
    event = "BufReadPost",
    ft = { "markdown", "pandoc.markdown", "rmd" },
  },

  -- Session manager
  {
    "Shatur/neovim-session-manager",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- local Path = require("plenary.path")
      require("session_manager").setup({
        autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
        autosave_last_session = true,
        autosave_ignore_not_normal = true,
        autosave_ignore_dirs = { "/", "~/" },
        autosave_ignore_filetypes = { "gitcommit" },
        autosave_only_in_session = true,
      })
    end,
  },

  -- File type templates
  {
    "mattn/sonictemplate-vim",
    cmd = "Template",
  },

  -- Auto ambiwidth
  {
    "delphinus/cellwidths.nvim",
    event = "BufReadPre",
    config = function()
      require("cellwidths").setup({
        name = "default",
      })
    end,
  },
  {
    "editorconfig/editorconfig-vim",
    event = "BufReadPre",
  },
  {
    "pseewald/vim-anyfold",
    event = "BufEnter",
    config = function()
      vim.cmd([[
                filetype plugin indent on
                syntax on
                augroup anyfold
                    autocmd!
                    autocmd Filetype * AnyFoldActivate
                augroup END
                let g:LargeFile = 1000000
                autocmd BufReadPre,BufRead * let f=getfsize(expand("<afile>")) | if f > g:LargeFile || f == -2 | call LargeFile() | endif
                function! LargeFile()
                    augroup anyfold
                        autocmd!
                        autocmd Filetype * setlocal foldmethod=indent
                    augroup END
                endfunction
                set foldlevel=20
            ]])
    end,
  },
  {
    "tyru/capture.vim",
    event = "VimEnter",
  },
  {
    "nvim-tree/nvim-tree.lua",
    event = "VimEnter",
    config = function()
      require("nvim-tree").setup()
    end,
  },
  {
    "yorickpeterse/nvim-pqf",
    event = "BufEnter",
    config = function()
      require("pqf").setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "nvim-cmp" },
    config = function()
      local npairs = require("nvim-autopairs")

      local Rule = require("nvim-autopairs.rule")
      -- local cond = require('nvim-autopairs.conds')
      -- local ts_conds = require('nvim-autopairs.ts-conds')

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local handlers = require("nvim-autopairs.completion.handlers")

      local cmp = require("cmp")

      npairs.setup({
        check_ts = true,
        ts_config = {
          -- lua = {'string'},
          -- python = {},
        },
        ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
      })

      -- add custom rules

      npairs.add_rule(Rule("$$", "$$", "tex"))

      -- press % => %% only while inside a comment or string
      -- npairs.add_rules({
      --   Rule("%", "%", "lua")
      --     :with_pair(ts_conds.is_ts_node({'string','comment'})), -- not working in this cond?
      --   Rule("$", "$", "lua")
      --     :with_pair(ts_conds.is_not_ts_node({'function'}))
      -- })

      cmp.event:on(
        "confirm_done",
        cmp_autopairs.on_confirm_done({
          filetypes = {
            -- "*" is a alias to all filetypes
            ["*"] = {
              ["("] = {
                kind = {
                  cmp.lsp.CompletionItemKind.Function,
                  cmp.lsp.CompletionItemKind.Method,
                },
                handler = handlers["*"],
              },
            },
            -- lua = {
            --   ["("] = {
            --     kind = {
            --       cmp.lsp.CompletionItemKind.Function,
            --       cmp.lsp.CompletionItemKind.Method
            --     },
            --     ---@param char string
            --     ---@param item table item completion
            --     ---@param bufnr number buffer number
            --     ---@param rules table
            --     ---@param commit_character table<string>
            --     handler = function(char, item, bufnr, rules, commit_character)
            --       -- Your handler function. Inspect with print(vim.inspect{char, item, bufnr, rules, commit_character})
            --     end
            --   }
            -- },
            -- Disable for tex
            tex = false,
            text = false,
          },
        })
      )
    end,
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "VimEnter",
    config = function()
      require("git-conflict").setup()
    end,
  },
  {
    "hedyhli/outline.nvim",
    event = "VimEnter",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("outline").setup({
        symbol_folding = {
          auto_unfold = { only = 2 },
        },
        preview_window = {
          auto_preview = true,
        },
      })
      vim.api.nvim_set_keymap("n", "[telescope]h", ":Outline<CR>", { noremap = true, silent = true })
    end,
  },
  {
    "t9md/vim-quickhl",
    event = "BufReadPre",
    config = function()
      vim.api.nvim_set_keymap("n", "<Leader>hl", "<Plug>(quickhl-manual-this)", {})
      vim.api.nvim_set_keymap("x", "<Leader>hl", "<Plug>(quickhl-manual-this)", {})
      vim.api.nvim_set_keymap("n", "<Leader>hc", "<Plug>(quickhl-manual-reset)", {})
      vim.api.nvim_set_keymap("x", "<Leader>hc", "<Plug>(quickhl-manual-reset)", {})
    end,
  },
  {
    "folke/todo-comments.nvim",
    version = "v1.*",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VimEnter",
    config = function()
      local c = require("onedark.colors")
      require("todo-comments").setup({
        colors = {
          error = { c.red },
          warning = { c.yellow },
          info = { c.blue },
          hint = { c.green },
          default = { c.green },
          test = { c.purple },
        },
      })
      vim.keymap.set("n", "]t", require("todo-comments").jump_next, { desc = "Next todo comment" })
      vim.keymap.set("n", "[t", require("todo-comments").jump_prev, { desc = "Previous todo comment" })
    end,
  },
  -- {
  --   "jackMort/ChatGPT.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim", "MunifTanjim/nui.nvim" },
  --   event = "VimEnter",
  --   config = function()
  --     require("chatgpt").setup({
  --       openai_params = {
  --         model = "gpt-3.5-turbo",
  --         max_tokens = 350,
  --       },
  --     })
  --   end,
  -- },
  {
    "frankroeder/parrot.nvim",
    dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
    event = "VimEnter",
    config = function()
      require("parrot").setup({
        -- Providers must be explicitly added to make them available.
        providers = {
          anthropic = {
            api_key = os.getenv("ANTHROPIC_API_KEY"),
          },
          gemini = {
            api_key = os.getenv("GEMINI_API_KEY"),
          },
          -- groq = {
          --   api_key = os.getenv("GROQ_API_KEY"),
          -- },
          -- mistral = {
          --   api_key = os.getenv("MISTRAL_API_KEY"),
          -- },
          pplx = {
            api_key = os.getenv("PERPLEXITY_API_KEY"),
          },
          -- provide an empty list to make provider available (no API key required)
          -- ollama = {},
          openai = {
            api_key = os.getenv("OPENAI_API_KEY"),
          },
          github = {
            api_key = os.getenv("GITHUB_TOKEN"),
          },
          -- nvidia = {
          --   api_key = os.getenv("NVIDIA_API_KEY"),
          -- },
          -- xai = {
          --   api_key = os.getenv("XAI_API_KEY"),
          -- },
        },
      })
    end,
  },
  {
    "dstein64/vim-startuptime",
    event = "VimEnter",
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    event = "BufReadPost",
  },
}
