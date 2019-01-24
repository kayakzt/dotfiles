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

let g:python_host_skip_check = 1

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

" Rename function
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))

" My autocmd
" formatting with yapf on save in *.py
" autocmd BufWritePre *.py 0,$!yapf
autocmd FileType python nnoremap <leader>y :0,$!yapf<Cr><C-o>
" close help window with 'q'
autocmd FileType help nnoremap <buffer> q <C-w>c
autocmd FileType godoc nnoremap <buffer> q <C-w>c

" Open junk file."{{{
command! -nargs=0 JunkFile call s:open_junk_file()
function! s:open_junk_file()
  let l:junk_dir = $HOME . '/.junk'. strftime('/%Y/%m')
  if !isdirectory(l:junk_dir)
    call mkdir(l:junk_dir, 'p')
  endif

  let l:filename = input('Junk Code: ', l:junk_dir.strftime('/%Y-%m-%d-%H%M%S.'))
  if l:filename != ''
    execute 'edit ' . l:filename
  endif
endfunction"}}}

" 縦分割版gf <C-w>+fで横分割, <C-w>+gfで新しいタブに開く
nnoremap gs :vertical wincmd f<CR>

" set python path
let g:python3_host_prog = $PYENV_ROOT . '/shims/python3'


" vim settings

set encoding=utf8

" Display
" syntax on
set number
set cursorline
"set cursorcolumn
set showmatch
set virtualedit=block
set list
set listchars=tab:¦_,trail:-,nbsp:%,eol:↲,extends:❯,precedes:❮
" set showbreak=↪

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
set splitright
set splitbelow
set completeopt=menuone,preview

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
" set clipboard=unnamed,unnamedplus
set clipboard^=unnamedplus
set mouse=a
set shellslash
"set wildmenu wildmode=list:longest,full
set history=10000
set visualbell t_vb=
set noerrorbells

" Highlight
hi Cursorline guibg=gray13

"for Japanese Input
set ttimeout
set ttimeoutlen=100

" KeyBindings
nnoremap Q gq
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>

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
