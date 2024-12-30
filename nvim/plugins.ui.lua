return {
  -- Onedark.nvim
  {
    "navarasu/onedark.nvim",
    lazy = false,
    config = function()
      local onedark = require("onedark")

      onedark.setup({
        style = "dark",
        toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
        toggle_style_list = { "dark", "darker", "warm", "warmer" }, -- List of styles to toggle between
        code_style = { -- italic, bold, underline, none
          comments = "italic,bold",
          keywords = "none",
          functions = "italic",
          strings = "none",
          variables = "none",
        },
        highlights = {},
      })
      onedark.load()
      -- vim.api.nvim_set_hl(0, "NonText", { ctermfg = 238, ctermbg = nil, guifg = "#444444", guibg = nil })
    end,
  },

  {
    "nvim-lua/plenary.nvim",
  },

  {
    "MunifTanjim/nui.nvim",
  },

  -- Fidget.nvim
  {
    "j-hui/fidget.nvim",
    version = "v1.*",
    event = "BufEnter",
    config = function()
      require("fidget").setup()
    end,
  },

  -- Lualine.nvim
  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    config = function()
      -- local function hasKey(table, key)
      --   return table[key] ~= nil
      -- end

      -- local lualine = require("lualine")

      -- Color table for highlights
      local c = require("onedark.colors")
      -- local cfg = vim.g.onedark_config

      local colors = {
        black = c.bg0,
        white = c.fg,
        red = c.red,
        green = c.green,
        yellow = c.yellow,
        orange = c.orange,
        blue = c.blue,
        purple = c.purple,
        cyan = c.cyan,
        grey = c.grey,
        light_grey = c.light_grey,
        bg1 = c.bg1,
        bg2 = c.bg2,
        bg3 = c.bg3,
        bg_d = c.bg_d,
      }

      local theme = {
        normal = {
          a = { fg = colors.black, bg = colors.green },
          b = { fg = colors.light_grey, bg = colors.bg3 },
          c = { fg = colors.white },
        },

        insert = { a = { fg = colors.black, bg = colors.blue } },
        visual = { a = { fg = colors.black, bg = colors.purple } },
        command = { a = { fg = colors.black, bg = colors.yellow } },
        terminal = { a = { fg = colors.bg, bg = colors.cyan } },
        replace = { a = { fg = colors.black, bg = colors.red } },

        inactive = {
          a = { fg = colors.black, bg = colors.grey },
          b = { fg = colors.white, bg = colors.black },
          c = { fg = colors.white },
        },
      }

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
          local filepath = vim.fn.expand("%:p:h")
          local gitdir = vim.fn.finddir(".git", filepath .. ";")
          return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
      }

      -- Config
      local config = {
        options = {
          globalstatus = false,
          -- Disable sections and component separators
          component_separators = "",
          section_separators = "",
          theme = theme,
        },
        sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          -- These will be filled later
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          -- these are to remove the defaults
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
        -- winbar = {
        --   lualine_a = {},
        --   lualine_b = {'filename'},
        --   lualine_c = {'buffers'},
        --   lualine_x = {'tabs'},
        --   lualine_y = {},
        --   lualine_z = {}
        -- },
        extensions = {
          "quickfix",
          "mason",
          "nvim-tree",
        },
      }

      -- Inserts a component in lualine_c at left section
      local function ins_left(loc, component)
        table.insert(loc, component)
      end

      -- Inserts a component in lualine_x at right section
      local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
      end

      ins_left(config.sections.lualine_a, {
        -- mode component
        "mode",
        padding = 1,
      })

      ins_left(config.sections.lualine_b, {
        "branch",
        shorting_target = 4,
        icon = "",
        -- color = { fg = colors.purple},
        cond = conditions.hide_in_width,
      })

      ins_left(config.sections.lualine_c, {
        "filename",
        shorting_target = 32,
        cond = conditions.buffer_not_empty,
        -- color = { fg = colors.green, gui = 'bold' },
      })

      ins_left(config.sections.lualine_c, {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        diagnostics_color = {
          error = { fg = colors.red },
          warn = { fg = colors.yellow },
          info = { fg = colors.cyan },
          hint = { fg = colors.purple },
        },
      })

      -- Insert mid section. You can make any number of sections in neovim :)
      -- for lualine it's any number greater then 2
      ins_left(config.sections.lualine_c, {
        function()
          return "%="
        end,
      })

      -- Add components to right sections
      ins_right({
        "o:encoding", -- option component same as &encoding in viml
        fmt = string.upper, -- I'm not sure why it's upper case either ;)
        cond = conditions.hide_in_width,
        -- color = { fg = colors.green, gui = 'bold' },
      })

      ins_right({
        "filetype",
        cond = conditions.hide_in_width,
        icons_enabled = false,
        color = { fg = colors.green },
      })

      ins_right({
        "fileformat",
        fmt = string.upper,
        icons_enabled = false,
        -- color = { fg = colors.green, gui = 'bold' },
        cond = conditions.hide_in_width,
      })

      ins_right({
        "diff",
        -- Is it me or the symbol for modified us really weird
        symbols = { added = " ", modified = "󰝤 ", removed = " " },
        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.cyan },
          removed = { fg = colors.purple },
        },
        cond = conditions.hide_in_width,
      })

      ins_right({
        "progress",
        color = { fg = colors.white },
        cond = conditions.hide_in_width,
      })

      ins_right({
        "location",
        color = { fg = colors.light_grey, bg = colors.bg3 },
      })

      -- Now don't forget to initialize lualine
      require("lualine").setup(config)
    end,
  },

  -- Web devicons
  {
    "nvim-tree/nvim-web-devicons",
  },

  -- Telescope plugins
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = { "tami5/sqlite.lua" },
  },

  -- Telescope.nvim
  {
    "nvim-telescope/telescope.nvim",
    version = "v0.1.*",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-frecency.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "fhill2/telescope-ultisnips.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local transform_mod = require("telescope.actions.mt").transform_mod
      local action_state = require("telescope.actions.state")
      local action_layout = require("telescope.actions.layout")
      local fb_actions = require("telescope").extensions.file_browser.actions

      -- multi open function
      local function multiopen(prompt_bufnr, method)
        local edit_file_cmd_map = {
          vertical = "vsplit",
          horizontal = "split",
          tab = "tabedit",
          default = "edit",
        }
        local edit_buf_cmd_map = {
          vertical = "vert sbuffer",
          horizontal = "sbuffer",
          tab = "tab sbuffer",
          default = "buffer",
        }
        local picker = action_state.get_current_picker(prompt_bufnr)
        local multi_selection = picker:get_multi_selection()

        if #multi_selection > 1 then
          require("telescope.pickers").on_close_prompt(prompt_bufnr)
          pcall(vim.api.nvim_set_current_win, picker.original_win_id)

          for i, entry in ipairs(multi_selection) do
            local filename, row, col

            if entry.path or entry.filename then
              filename = entry.path or entry.filename

              row = entry.row or entry.lnum
              col = vim.F.if_nil(entry.col, 1)
            elseif not entry.bufnr then
              local value = entry.value
              if not value then
                return
              end

              if type(value) == "table" then
                value = entry.display
              end

              local sections = vim.split(value, ":")

              filename = sections[1]
              row = tonumber(sections[2])
              col = tonumber(sections[3])
            end

            local entry_bufnr = entry.bufnr

            if entry_bufnr then
              if not vim.api.nvim_buf_get_option(entry_bufnr, "buflisted") then
                vim.api.nvim_buf_set_option(entry_bufnr, "buflisted", true)
              end
              local command = i == 1 and "buffer" or edit_buf_cmd_map[method]
              pcall(vim.cmd, string.format("%s %s", command, vim.api.nvim_buf_get_name(entry_bufnr)))
            else
              local command = i == 1 and "edit" or edit_file_cmd_map[method]
              if vim.api.nvim_buf_get_name(0) ~= filename or command ~= "edit" then
                filename = require("plenary.path"):new(vim.fn.fnameescape(filename)):normalize(vim.loop.cwd())
                pcall(vim.cmd, string.format("%s %s", command, filename))
              end
            end

            if row and col then
              pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
            end
          end
        else
          actions["select_" .. method](prompt_bufnr)
        end
      end

      local custom_actions = transform_mod({
        multi_selection_open_vertical = function(prompt_bufnr)
          multiopen(prompt_bufnr, "vertical")
        end,
        multi_selection_open_horizontal = function(prompt_bufnr)
          multiopen(prompt_bufnr, "horizontal")
        end,
        multi_selection_open_tab = function(prompt_bufnr)
          multiopen(prompt_bufnr, "tab")
        end,
        multi_selection_open = function(prompt_bufnr)
          multiopen(prompt_bufnr, "default")
        end,
      })

      local function stopinsert(callback)
        return function(prompt_bufnr)
          vim.cmd.stopinsert()
          vim.schedule(function()
            callback(prompt_bufnr)
          end)
        end
      end

      local multi_open_mappings = {
        i = {
          ["<M-v>"] = stopinsert(custom_actions.multi_selection_open_vertical),
          ["<M-s>"] = stopinsert(custom_actions.multi_selection_open_horizontal),
          ["<M-t>"] = stopinsert(custom_actions.multi_selection_open_tab),
          ["<CR>"] = stopinsert(custom_actions.multi_selection_open),
        },
        n = {
          ["<M-v>"] = custom_actions.multi_selection_open_vertical,
          ["<M-s>"] = custom_actions.multi_selection_open_horizontal,
          ["<M-t>"] = custom_actions.multi_selection_open_tab,
          ["<CR>"] = custom_actions.multi_selection_open,
        },
      }

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-u>"] = actions.results_scrolling_up,
              ["<C-d>"] = actions.results_scrolling_down,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
              ["<M-p>"] = action_layout.toggle_preview,
            },
            n = {
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["<C-u>"] = actions.results_scrolling_up,
              ["<C-d>"] = actions.results_scrolling_down,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
              ["<M-p>"] = action_layout.toggle_preview,
            },
          },
          vimgrep_arguments = {
            "rg",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--hidden",
            "--smart-case",
            "--glob",
            "!**/node_modules/*",
            "--glob",
            "!**/.git/*",
            "--glob",
            "!.gitignore",
            "--glob",
            "!**/.venv/*",
            "--glob",
            "!**/*.lock",
            "--trim",
          },
          file_ignore_patterns = { "^node_modules/", "^./.git/", "^./.venv/" },
        },
        pickers = {
          find_files = {
            find_command = {
              "rg",
              "--files",
              "--hidden",
              "--smart-case",
              "--glob",
              "!**/node_modules/*",
              "--glob",
              "!**/.git/*",
              "--glob",
              "!**/.venv/*",
            },
            mappings = {
              i = {
                ["<M-v>"] = stopinsert(custom_actions.multi_selection_open_vertical),
                ["<M-s>"] = stopinsert(custom_actions.multi_selection_open_horizontal),
                ["<M-t>"] = stopinsert(custom_actions.multi_selection_open_tab),
                ["<CR>"] = stopinsert(custom_actions.multi_selection_open),
              },
              n = {
                ["<M-v>"] = custom_actions.multi_selection_open_vertical,
                ["<M-s>"] = custom_actions.multi_selection_open_horizontal,
                ["<M-t>"] = custom_actions.multi_selection_open_tab,
                ["<CR>"] = custom_actions.multi_selection_open,
                ["cd"] = function(prompt_bufnr)
                  local selection = require("telescope.actions.state").get_selected_entry()
                  local dir = vim.fn.fnamemodify(selection.path, ":p:h")
                  require("telescope.actions").close(prompt_bufnr)
                  vim.cmd(string.format("silent cd %s", dir))
                  vim.cmd(":Telescope find_files")
                end,
              },
            },
          },
          buffers = {
            sort_mru = true,
            mappings = multi_open_mappings,
          },
          live_grep = {
            mappings = multi_open_mappings,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          file_browser = {
            -- theme = "ivy",
            hidden = true,
            hijack_netrw = true,
            mappings = {
              i = {
                ["<M-v>"] = stopinsert(custom_actions.multi_selection_open_vertical),
                ["<M-s>"] = stopinsert(custom_actions.multi_selection_open_horizontal),
                ["<M-t>"] = stopinsert(custom_actions.multi_selection_open_tab),
                ["<CR>"] = stopinsert(custom_actions.multi_selection_open),
                ["<M-h>"] = fb_actions.goto_parent_dir,
                ["<M-.>"] = fb_actions.toggle_hidden,
                ["<M-p>"] = fb_actions.change_cwd,
              },
              n = {
                ["<M-v>"] = custom_actions.multi_selection_open_vertical,
                ["<M-s>"] = custom_actions.multi_selection_open_horizontal,
                ["<M-t>"] = custom_actions.multi_selection_open_tab,
                ["<CR>"] = custom_actions.multi_selection_open,
                ["<M-h>"] = fb_actions.goto_parent_dir,
                ["<M-.>"] = fb_actions.toggle_hidden,
                ["<M-p>"] = fb_actions.change_cwd,
              },
            },
          },
          coc = {
            -- theme = 'ivy',
            prefer_locations = true,
          },
          frecency = {
            show_scores = false,
            show_unindexed = true,
            db_safe_mode = false,
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("frecency")
      telescope.load_extension("file_browser")
      telescope.load_extension("ui-select")
      telescope.load_extension("ultisnips")

      -- Define key mappings for Telescope
      vim.keymap.set("n", "<C-p>", "[telescope]", { noremap = true, silent = true, remap = true })
      vim.keymap.set("n", "[telescope]f", ":Telescope find_files<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]F", ":Telescope find_files no_ignore=true<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]r", ":Telescope frecency<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]g", ":Telescope live_grep<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]G", function()
        vim.cmd("Telescope live_grep default_text=" .. vim.fn.expand("<cword>"))
      end, { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]v", ":Telescope git_files<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]b", ":Telescope buffers<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]j", ":Telescope jumplist<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]T", ":Telescope filetypes<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]y", ":Telescope registers<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]m", ":Telescope marks<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]q", ":Telescope command_history<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]H", ":Telescope help_tags<CR>", { noremap = true, silent = true })
      vim.keymap.set(
        "n",
        "[telescope]n",
        ":Telescope find_files cwd=$MY_NOTE_DIR<CR>",
        { noremap = true, silent = true }
      )
      vim.keymap.set(
        "n",
        "[telescope]N",
        ":Telescope live_grep cwd=$MY_NOTE_DIR<CR>",
        { noremap = true, silent = true }
      )

      -- Uncomment the following line if needed
      -- vim.keymap.set('n', '[telescope]o', ':Telescope treesitter<CR>', { noremap = true, silent = true })

      vim.keymap.set("n", "[telescope]c", ":Telescope git_commits<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]e", function()
        require("telescope.builtin").symbols({ sources = { "emoji", "gitmoji" } })
      end, { noremap = true, silent = true })
      vim.keymap.set("n", "[telescope]o", ":Telescope file_browser<CR>", { noremap = true, silent = true })

      vim.keymap.set(
        "n",
        "[telescope]s",
        ":SessionManager load_current_dir_session<CR>",
        { noremap = true, silent = true }
      )
      vim.keymap.set("n", "[telescope]S", ":SessionManager load_session<CR>", { noremap = true, silent = true })

      vim.keymap.set("n", "[telescope]t", ":TodoTelescope<CR>", { noremap = true, silent = true })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    version = "v4.*",
    event = "VimEnter",
    dependencies = { "nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          style_preset = require("bufferline").style_preset.minimal,
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icons = { error = " ", warn = " ", info = " ", hint = " " }
            return " " .. (icons[level] or " ") .. count
          end,
        },
      })
    end,
  },
  {
    "nvimdev/lspsaga.nvim",
    event = "BufReadPost",
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
