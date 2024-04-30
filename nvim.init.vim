set encoding=utf8
scriptencoding utf-8

" Set Color Mode
if (has('termguicolors'))
    set termguicolors
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" set mapleader
let mapleader = "\<Space>"

" XDG Set
let g:cache_home = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let g:config_home = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME

" Initialization
" set nocompatible

" if !&compatible
"     map ^[OA ^[ka
"     map ^[OB ^[ja
"     map ^[OC ^[la
"     map ^[OD ^[ha
" endif

let g:python_host_skip_check = 1

" reset my augroup
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
let &runtimepath = s:dein_repo_dir .','. &runtimepath
" プラグイン読み込み＆キャッシュ作成
let s:toml = expand('$HOME/.config/nvim/dein.toml')
let s:toml_lazy = expand('$HOME/.config/nvim/dein_lazy.toml')
if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)

    if getftype(s:toml) !=# ''
        call dein#load_toml(s:toml,{'lazy' : 0})
    endif

    if getftype(s:toml_lazy) !=# ''
        call dein#load_toml(s:toml_lazy,{'lazy' : 1})
    endif

    call dein#end()
    " call dein#save_state()
endif

" automatic plugin installation
if dein#check_install()
    call dein#install()
endif

" set colorscheme
if getftype(s:toml_lazy) ==# ''
    colorscheme elflord
endif

if has('filetype')
    filetype indent plugin on
endif

if has('syntax')
    syntax on
endif

" }}}

" Rename function
command! -nargs=1 -complete=file FileRename f <args>|call delete(expand('#'))

" Copy function
command! -nargs=1 -complete=file FileCopy f <args>

" Delete function
command! -nargs=0 FileDelete call delete(expand('#'))

" Open note file."{{{
command! -nargs=0 NoteCreate call s:open_note_file()
function! s:open_note_file()
    let l:note_dir = $MY_NOTE_DIR. strftime('/%Y/%m')
    if !isdirectory(l:note_dir)
        call mkdir(l:note_dir, 'p')
    endif

    let l:filename = input('Note: ', l:note_dir.strftime('/%Y-%m-%d-%H%M%S'). '.md')
    if l:filename !=# ''
        execute 'edit ' . l:filename
    endif
endfunction"}}}

" vim settings

set conceallevel=0

" set python path for neovim
let g:python3_host_prog = $PYENV_ROOT . '/shims/python3'

" Display
set number
set cursorline
"set cursorcolumn
set showmatch
set virtualedit=block
set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set ambiwidth=single

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
set completeopt=menuone

" Search / Replace
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan

" Tab / Indent
set expandtab
set tabstop=4
set softtabstop=-1
set shiftwidth=0
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
nnoremap Y y$

nnoremap gn :bn<cr>
nnoremap gp :bp<cr>

" for japanese input

" 矢印キーでなら行内を動けるように
noremap <Down> gj
noremap <Up>   gk

" 縦分割版gf <C-w>+fで横分割, <C-w>+gfで新しいタブに開く
nnoremap gs :vertical wincmd f<CR>

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

" custom vimgrep
if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
command! -nargs=* -complete=file Rg :tabnew | :silent grep --sort-files <args> | cw
command! -nargs=* -complete=file Rgg :tabnew | :silent grep <args> | cw

" set MyAutoCmd
augroup MyAutoCmd
    autocmd!
    " close help window with 'q'
    autocmd FileType help nnoremap <buffer> q <C-w>c
    autocmd FileType godoc nnoremap <buffer> q <C-w>c

    " show preview window during the completion mode
    " autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
    autocmd FileType vue syntax sync fromstart

    " auto close quickfix window after press CR
    autocmd FileType qf nnoremap <buffer> <CR> <CR><Cmd>cclose<CR>
    " don't close quickfix window with ctrl-j
    autocmd FileType qf nnoremap <buffer> <C-j> <CR>

    " completion settings
    " autocmd BufRead,BufNewFile *.py set completeopt=menuone,preview
    " autocmd BufRead,BufNewFile *.go set completeopt=menuone,preview
augroup END

" Terminal Function
let g:term_buf = 0
let g:term_win = 0
function! TermToggle(height)
    if win_gotoid(g:term_win)
        hide
    else
        botright new
        exec 'resize ' . a:height
        try
            exec 'buffer ' . g:term_buf
        catch
            call termopen($SHELL, {'detach': 0})
            let g:term_buf = bufnr('')
            set nonumber
            set norelativenumber
            set signcolumn=no
        endtry
        startinsert!
        let g:term_win = win_getid()
    endif
endfunction

" Toggle terminal on/off (neovim)
nnoremap <A-t> :call TermToggle(12)<CR>
inoremap <A-t> <Esc>:call TermToggle(12)<CR>
tnoremap <A-t> <C-\><C-n>:call TermToggle(12)<CR>

" Terminal go back to normal mode
tnoremap <Esc> <C-\><C-n>
tnoremap :q! <C-\><C-n>:q!<CR>
