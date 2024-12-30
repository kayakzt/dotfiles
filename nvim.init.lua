-- 文字コード設定
vim.opt.encoding = "utf-8"

-- カラーモード設定
if not vim.fn.has("gui_running") and vim.fn.has("termguicolors") and vim.opt.term:match("screen|tmux") then
  vim.opt.termguicolors = true
  vim.opt.t_8f = "\x1b[38;2;%lu;%lu;%lum"
  vim.opt.t_8b = "\x1b[48;2;%lu;%lu;%lum"
end

-- leaderキーの設定
vim.g.mapleader = " "

-- XDGディレクトリ設定
vim.g.cache_home = vim.env.XDG_CACHE_HOME or vim.fn.expand("~/.cache")
vim.g.config_home = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")

vim.g.python_host_skip_check = 1

-- augroup設定をリセット
vim.api.nvim_create_augroup("MyAutoCmd", { clear = true })

-- dein.vimの設定
local dein_dir = vim.g.cache_home .. "/dein"
local dein_repo_dir = dein_dir .. "/repos/github.com/Shougo/dein.vim"

if not vim.loop.fs_stat(dein_repo_dir) then
  vim.fn.system({ "git", "clone", "https://github.com/Shougo/dein.vim", dein_repo_dir })
end

vim.opt.runtimepath:prepend(dein_repo_dir)

if vim.fn["dein#load_state"](dein_dir) == 1 then
  vim.fn["dein#begin"](dein_dir)

  local toml = vim.fn.expand("$HOME/.config/nvim/dein.toml")
  local toml_lazy = vim.fn.expand("$HOME/.config/nvim/dein_lazy.toml")

  if vim.fn.getftype(toml) ~= "" then
    vim.fn["dein#load_toml"](toml, { lazy = 0 })
  end

  if vim.fn.getftype(toml_lazy) ~= "" then
    vim.fn["dein#load_toml"](toml_lazy, { lazy = 1 })
  end

  vim.fn["dein#end"]()
end

if vim.fn["dein#check_install"]() == 1 then
  vim.fn["dein#install"]()
end

if vim.fn.getftype(vim.fn.expand("$HOME/.config/nvim/dein_lazy.toml")) == "" then
  vim.cmd("colorscheme elflord")
end

if vim.fn.has("filetype") == 1 then
  vim.cmd("filetype indent plugin on")
end

if vim.fn.has("syntax") == 1 then
  vim.cmd("syntax on")
end

-- Rename function
vim.api.nvim_create_user_command("FileRename", function(opts)
  local current_file = vim.fn.expand("#")
  if vim.fn.delete(current_file) == 0 then
    vim.cmd("edit " .. opts.args)
  else
    print("Failed to delete: " .. current_file)
  end
end, { nargs = 1, complete = "file" })

-- Copy function
vim.api.nvim_create_user_command("FileCopy", function(opts)
  local current_file = vim.fn.expand("#")
  if vim.fn.copy(current_file, opts.args) == 0 then
    print("File copied to: " .. opts.args)
  else
    print("Failed to copy file.")
  end
end, { nargs = 1, complete = "file" })

-- Delete function
vim.api.nvim_create_user_command("FileDelete", function()
  local current_file = vim.fn.expand("#")
  if vim.fn.delete(current_file) == 0 then
    print("File deleted: " .. current_file)
  else
    print("Failed to delete file.")
  end
end, { nargs = 0 })

-- Open note file
vim.api.nvim_create_user_command("NoteCreate", function()
  local note_dir = vim.env.MY_NOTE_DIR .. os.date("/%Y/%m")
  if not vim.loop.fs_stat(note_dir) then
    vim.fn.mkdir(note_dir, "p")
  end

  local default_filename = note_dir .. os.date("/%Y-%m-%d-%H%M%S") .. ".md"
  local filename = vim.fn.input("Note: ", default_filename)
  if filename ~= "" then
    vim.cmd("edit " .. filename)
  end
end, { nargs = 0 })

-- Neovim 表示設定
local ui_options = {
  number = true,
  cursorline = true,
  list = true,
  listchars = {
    tab = "»-",
    trail = "-",
    eol = "↲",
    extends = "»",
    precedes = "«",
    nbsp = "%",
  },
}

-- カーソル、バッファ、検索、タブ/インデント設定
local editing_options = {
  whichwrap = "b,s,h,l,<,>,[,]",
  scrolloff = 8,
  sidescrolloff = 16,
  confirm = true,
  hidden = true,
  hlsearch = true,
  incsearch = true,
  ignorecase = true,
  smartcase = true,
  wrapscan = true,
  expandtab = true,
  tabstop = 4,
  shiftwidth = 4,
  autoindent = true,
  smartindent = true,
}

-- クリップボードとOS連携
local system_integration = {
  mouse = "a",
}

-- 設定の適用
for k, v in pairs(ui_options) do
  vim.opt[k] = v
end

for k, v in pairs(editing_options) do
  vim.opt[k] = v
end

vim.opt.clipboard:append("unnamedplus")
vim.opt.mouse = system_integration.mouse

-- カスタムキー設定
local keymaps = {
  -- ノーマルモード
  n = {
    { "Q", "gq" },
    { "ZZ", "<Nop>" },
    { "ZQ", "<Nop>" },
    { "Y", "y$" },
    { "gn", ":bn<CR>" },
    { "gp", ":bp<CR>" },
    { "gs", ":vertical wincmd f<CR>" },
  },
  -- 挿入モード
  i = {
    { "<C-j>", "<Down>" },
    { "<C-k>", "<Up>" },
    { "<C-h>", "<Left>" },
    { "<C-l>", "<Right>" },
  },
}

-- キーマップの適用
for mode, mappings in pairs(keymaps) do
  for _, map in ipairs(mappings) do
    vim.keymap.set(mode, map[1], map[2])
  end
end

-- 検索とgrep設定
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --no-heading"
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- MyAutoCmd (自動コマンド)
local my_auto_cmd = vim.api.nvim_create_augroup("MyAutoCmd", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = my_auto_cmd,
  pattern = { "help", "godoc" },
  callback = function()
    vim.keymap.set("n", "q", "<C-w>c", { buffer = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = my_auto_cmd,
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "<CR>", "<CR><Cmd>cclose<CR>", { buffer = true })
    vim.keymap.set("n", "<C-j>", "<CR>", { buffer = true })
  end,
})

-- Customise f-motion for Japanese input
vim.keymap.set("n", "fj", "f<C-k>j", { noremap = true, silent = true })
vim.keymap.set("n", "Fj", "F<C-k>j", { noremap = true, silent = true })
vim.keymap.set("n", "tj", "t<C-k>j", { noremap = true, silent = true })
vim.keymap.set("n", "Tj", "T<C-k>j", { noremap = true, silent = true })

-- Define custom digraphs
local digraphs = {
  { "jj", 106 }, -- j follows fj command
  { "j(", 65288 }, -- （
  { "j)", 65289 }, -- ）
  { "j[", 12300 }, -- 「
  { "j]", 12301 }, -- 」
  { "j{", 12302 }, -- 『
  { "j}", 12303 }, -- 』
  { "j<", 12304 }, -- 【
  { "j>", 12305 }, -- 】
  { "j,", 12289 }, -- 、
  { "j.", 12290 }, -- 。
  { "j!", 65281 }, -- ！
  { "j?", 65311 }, -- ？
  { "j:", 65306 }, -- ：
  { "j0", 65296 }, -- ０
  { "j1", 65297 }, -- １
  { "j2", 65298 }, -- ２
  { "j3", 65299 }, -- ３
  { "j4", 65300 }, -- ４
  { "j5", 65301 }, -- ５
  { "j6", 65302 }, -- ６
  { "j7", 65303 }, -- ７
  { "j8", 65304 }, -- ８
  { "j9", 65305 }, -- ９
  { "j-", 12540 }, -- ー
  { "j~", 12316 }, -- 〜
  { "j/", 12539 }, -- ・
  { "js", 12288 }, -- 全角スペース
  { "j@", 65312 }, -- ＠
}

for _, digraph in ipairs(digraphs) do
  local char, code = digraph[1], digraph[2]
  vim.cmd(string.format("digraphs %s %d", char, code))
end
