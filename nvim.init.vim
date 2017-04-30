" Color Mode Set

let $NVIM_TUI_ENABLE_TRUE_COLOR=1
if (has("termguicolors"))
  set termguicolors
endif

" XDG Set

let g:cache_home = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let g:config_home = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME

" Initialization

if !&compatible
  set nocompatible
endif

" reset augroup
augroup MyAutoCmd
  autocmd!
augroup END

" dein settings {{{

" dein自体の自動インストール
let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif
let &runtimepath = s:dein_repo_dir .",". &runtimepath
" プラグイン読み込み＆キャッシュ作成
" let s:toml_file = fnamemodify(expand('<sfile>'), ':h').'/dein.toml'
let s:toml = '~/.config/nvim/dein.toml'
let s:toml_lazy = '~/.config/nvim/dein_lazy.toml'
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)
  call dein#load_toml(s:toml,{'lazy' : 0})
  call dein#load_toml(s:toml_lazy,{'lazy' : 1})
  call dein#end()
  call dein#save_state()
endif

" 不足プラグインの自動インストール
if has('vim_starting') && dein#check_install()
  call dein#install()
endif

" }}}



" vim settings

" Display
" syntax on
set number
set cursorline
"set cursorcolumn
set showmatch
set list
set listchars=tab:¦_,trail:-,nbsp:%,eol:↲,extends:❯,precedes:❮
set showbreak=↪

" Cursor
"set backspace=indent,eol,start
set whichwrap=b,s,h,l,<,>,[,]
set scrolloff=8
set sidescrolloff=16

" Buffer
set confirm
set hidden
set autoread
set nobackup
set noswapfile
set completeopt=menuone

" Search / Replace
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan
set gdefault

" Tab / Indent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent

" Integration with OS
set clipboard=unnamed,unnamedplus
set mouse=a
set shellslash
"set wildmenu wildmode=list:longest,full
set history=10000
set visualbell t_vb=
set noerrorbells


" KeyBindings

" for japanese input

" 矢印キーでなら行内を動けるように
noremap <Down> gj
noremap <Up>   gk

" 入力モードでのカーソル移動
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
" 日本語入力がオンのままでも使えるコマンド(Enterキーは必要)
nnoremap あ a
nnoremap い i
nnoremap う u
nnoremap お o
nnoremap っｄ dd
nnoremap っｙ yy
" 中身を変更する
nnoremap し” ci"
nnoremap し’ ci'
nnoremap し（ ci(
" jjでエスケープ
inoremap <silent> jj <ESC>
" 日本語入力で”っj”と入力してもEnterキーで確定させればインサートモードを抜ける
inoremap <silent> っｊ <ESC>

" インデント後にビジュアルモードが解除されないようにする
vnoremap < <gv
vnoremap > >gv

