#
# .zshrc
#
# This script depends on following script/directory
#
# # * cdr [$HOME/.cache/shell/]
# * enchancd [$HOME/.cache/shell/enhancd/]
# * peco [/usr/local/bin/peco]
# * zplug [$HOME/.zplug/]
# * go [$HOME/go]
# * cargo [$HOME/.cargo/bin]
# * nvm [$HOME/.nvm/]
# * rbenv [$HOME/.rbenv/]
#


#
# Initial Settings
#

# autoload -Uz promptinit
autoload -U colors && colors
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# autocompile
if [ ! -f ~/.zshrc.zwc -o ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

# Keybindings
bindkey -e
setopt IGNOREEOF # prevent ctrl+d shell exit

# cdr Settings
# autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
# add-zsh-hook chpwd chpwd_recent_dirs
# zstyle ':completion:*' recent-dirs-insert both
# zstyle ':chpwd:*' recent-dirs-max 500
# zstyle ':chpwd:*' recent-dirs-default true
# zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/shell/chpwd-recent-dirs"
# zstyle ':chpwd:*' recent-dirs-pushd true


#
# Prompt Settings
#

# vcs_info Settings
autoload -Uz vcs_info
precmd () { vcs_info }
setopt prompt_subst

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{green}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{magenta}±"
zstyle ':vcs_info:*' formats "%F{cyan} (%b%c%u%F{cyan})%f"
zstyle ':vcs_info:*' actionformats '%F{cyan} [%b|%F{magenta}%a%F{cyan}]'

# prompt
PROMPT="%B%{$fg[green]%}• %{$fg[yellow]%}• %{$fg[red]%}• %b%{$reset_color%}"
RPROMPT="%{$fg[white]%}[%~]%{$reset_color%}"
RPROMPT=$RPROMPT'${vcs_info_msg_0_}'


#
# Completion Settings
#

# autoload -U compinit; compinit
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ''
# zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*' keep-prefix
zstyle ':completion:*' recent-dirs-insert both

zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $HOME/.cache/shell

setopt auto_param_slash      # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt mark_dirs             # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt list_types            # 補完候補一覧でファイルの種別を識別マーク表示 (訳注:ls -F の記号)
setopt auto_menu             # 補完キー連打で順に補完候補を自動で補完
setopt auto_param_keys       # カッコの対応などを自動的に補完
setopt interactive_comments  # コマンドラインでも # 以降をコメントと見なす
setopt magic_equal_subst     # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる

setopt complete_in_word      # 語の途中でもカーソル位置で補完
setopt always_last_prompt    # カーソル位置は保持したままファイル名一覧を順次その場で表示

setopt extended_glob  # 拡張グロブで補完(~とか^とか。例えばless *.txt~memo.txt ならmemo.txt 以外の *.txt にマッチ)
setopt globdots # 明確なドットの指定なしで.から始まるファイルをマッチ

bindkey "^I" menu-complete   # 展開する前に補完候補を出させる(Ctrl-iで補完)


#
# peco functions
#

function peco-select-history() {
    # historyを番号なし、逆順、最初から表示。
    # 順番を保持して重複を削除。
    # カーソルの左側の文字列をクエリにしてpecoを起動
    # \nを改行に変換
    BUFFER="$(history -nr 1 | peco --select-1 --query "$LBUFFER" --prompt "[history]" | sed 's/\\n/\n/')"
    CURSOR=$#BUFFER             # カーソルを文末に移動
    zle -R -c                   # refresh
}
zle -N peco-select-history
bindkey '^R' peco-select-history

# function peco-cdr () {
#     local selected_dir="$(cdr -l | sed 's/^[0-9]\+ \+//' | peco --select-1 --prompt="cdr >" --query "$LBUFFER")"
#     if [ -n "$selected_dir" ]; then
#         BUFFER="cd ${selected_dir}"
#        zle accept-line
#     fi
# }
# zle -N peco-cdr
# bindkey '^[r' peco-cdr

function kill-peco() {
    for pid in `ps aux | peco --prompt '[kill?]' | awk '{ print $2 }'`
    do
        kill $pid
        echo "Killed ${pid}"
    done
}

function github-star-import() {
  # git, curl, jq, peco, ghq required
  if [ -n "$1" ]; then
    user_id=$1
  elif [ -n "$(git config --get github.user)" ]; then
    user_id=$(git config --get github.user)
  elif [ -n "$(git config --get user.name)" ]; then
    user_id=$(git config --get user.name)
  else
    echo "usage: github-star-import [<user_id>]"
    return 0
  fi

  urls=$(curl -s https://api.github.com/users/$user_id/starred\?per_page\=1000 | jq '.[] | .ssh_url' | awk '{gsub("\"", "");print $0;}')
  echo $urls | peco | ghq import
}

# This fuction depends on ripgrep
function shell_search() {
  local filepath="$(rg -p --smart-case --hidden --files --color never -g "!.git/" | peco --prompt '[search]')"
  [ -z "$filepath" ] && return
  if [ -n "$LBUFFER" ]; then
    BUFFER="$LBUFFER$filepath"
  else
    if [ -d "$filepath" ]; then
      BUFFER="cd $filepath"
    else
      BUFFER="$EDITOR $filepath"
    fi
  fi
  CURSOR=$#BUFFER
}

zle -N shell_search
bindkey '^[s' shell_search

#
# Alias
#

alias reload_zsh='source ~/.zshrc'

alias '..'='cd ..'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias cdh='cd $HOME'

alias -g @g='| grep'
alias -g @l='| less -R'
alias -g @j='| jq -C'
alias -g @jl='| jq "." -C | less -R'
alias -g @h='| head'
alias -g @t='| tail'
alias -g @s='| sed'
alias -g @c='| less -XF'
alias -g @p='| peco'
alias -g @em='| emojify'

alias ls='ls --color'
alias la='ls --color -lahF'
alias ll='ls --color -lhF'

alias al='ag --pager "less -R"'
alias agh='ag --hidden'
alias alh='ag --pager "less -R" --hidden'

alias ripl='(){rg -p $@ | less -R}'

alias -g gbl='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'
alias dps='docker ps --format "{{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Command}}\t{{.RunningFor}}"'
alias dex='docker exec -it `dps | peco | cut -f 1` /bin/bash'

alias termi='terminator -l medium'
alias termis='terminator -l small'
alias termim='terminator -l medium'
alias termil='terminator -l large'

# alias tmux='env TERM=xterm-256color tmux'
alias nv='nvim'

alias showtime='date & time'
alias sht='date & time'

alias di='dicto'
alias de='dicto -e'

# ghq & hub alias (with peco)
alias cdg='cd $(ghq root)/$(ghq list | peco --prompt "[ghq src]")'
alias ghq-cd='cd $(ghq root)/$(ghq list | peco --prompt "[ghq src]")'
alias hubb='hub browse $(ghq list | peco --prompt "[browse src]" | cut -d "/" -f 2,3)'

alias apt-update='sudo apt-get update \
                    && sudo apt-get upgrade \
                    && sudo apt-get dist-upgrade \
                    && sudo apt-get autoclean \
                    && sudo apt-get autoremove'
alias apt-update-yes='sudo apt-get update \
                    && sudo apt-get upgrade -y \
                    && sudo apt-get dist-upgrade -y \
                    && sudo apt-get autoclean -y \
                    && sudo apt-get autoremove -y'
alias pip-update-all='pip freeze --local \
                    | grep -v "^\-e" \
                    | cut -d = -f 1 \
                    | xargs pip install -U --user'
# alias pip3-update-all='pip3 freeze --local \
#                     | grep -v "^\-e" \
#                     | cut -d = -f 1 \
#                     | xargs pip3 install -U --user'

# auto unzip function
function auto_unzip() {
  case $1 in
    *.tar.gz|*.tgz) tar xzvf $1;;
    *.tar.xz) tar Jxvf $1;;
    *.zip) unzip $1;;
    *.lzh) lha e $1;;
    *.tar.bz2|*.tbz) tar xjvf $1;;
    *.tar.Z) tar zxvf $1;;
    *.gz) gzip -d $1;;
    *.bz2) bzip2 -dc $1;;
    *.Z) uncompress $1;;
    *.tar) tar xvf $1;;
    *.arj) unarj $1;;
  esac
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=auto_unzip

#
# Package Manager
#

# zplug
export ZPLUG_HOME=~/.zplug
export ZPLUG_CACHE_DIR=~/.cache/zplug
if [ ! -d $ZPLUG_HOME ]; then
  git clone https://github.com/zplug/zplug $ZPLUG_HOME
fi

if [ -f $ZPLUG_HOME/init.zsh ]; then
  source $ZPLUG_HOME/init.zsh

  # Variables
  export ENHANCD_DIR="$HOME/.config/shell/enhancd"
  export ENHANCD_FILTER="peco:fzf:fzy"
  export ENHANCD_COMMAND="cd"
  export ENHANCD_HYPHEN_ARG="ls"
  export ENHANCD_DOT_ARG="up"
  export EMOJI_CLI_KEYBIND="^[em"
  export EMOJI_CLI_FILTER="peco:fzf:fzy"
  export EMOJI_CLI_USE_EMOJI=0

  # Plugins
  # zplug "~/.zsh", from:local
  zplug "zsh-users/zsh-completions", depth:1
  zplug "zsh-users/zsh-syntax-highlighting", defer:2
  zplug "b4b4r07/enhancd", use:init.sh, at:v2.2.4
  zplug "b4b4r07/emoji-cli"
  zplug "mrowa44/emojify", as:command
  # zplug 'zplug/zplug', hook-build:'zplug --self-manage'

  # Install plugins if there are plugins that have not been installed
  if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
      echo; zplug install
    fi
  fi

  # Then, source plugins and add commands to $PATH
  zplug load
fi


#
# Other Settings
#

setopt no_beep
setopt transient_rprompt
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
eval "$(direnv hook zsh)"

# X forwarding Settings
if [ -n "$SSH_CONNECTION" ] ; then
  export DefaultIMModule=ibus
  export GTK_IM_MODULE=ibus
  export QT_IM_MODULE=ibus

  # export IBUS_ENABLE_SYNC_MODE=1
  # export NO_AT_BRIDGE=1
  #
  # if test `ps auxw | grep $USER | grep -v grep | grep "fcitx -d" 2> /dev/null | wc -l` -eq 0;
  # then
  #   fcitx -d > /dev/null 2>&1 &
  # fi

  if [ -z "$XMODIFIERS" ]; then
    export XMODIFIERS=@im=ibus
    ibus-daemon -drx
  else
    ibus-daemon -dr
  fi
fi

