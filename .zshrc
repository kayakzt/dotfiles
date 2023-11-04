#
# .zshrc
#

#
# Initial Settings
#

# autoload -Uz promptinit
autoload -U colors && colors
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# function source {
#   ensure_zcompiled $1
#   builtin source $1
# }

function ensure_zcompiled {
  local compiled="$1.zwc"
  if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
    echo "\033[1;36mCompiling\033[m $1"
    zcompile $1
  fi
}

# autocompile myself
ensure_zcompiled ~/.zshrc

# Keybindings
bindkey -e
bindkey -r '^q'
bindkey -r '^o'
bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
setopt IGNOREEOF # prevent ctrl+d shell exit


#
# Package Manager
#

# Variable for packages
export ENHANCD_DIR="$HOME/.config/shell/enhancd"
export ENHANCD_FILTER="fzf:peco"
export ENHANCD_COMMAND="cd"
export ENHANCD_ARG_DOUBLE_DOT="up"
export ENHANCD_ARG_SINGLE_DOT="ls"
export EMOJI_CLI_KEYBIND="^oe"
export EMOJI_CLI_FILTER="fzf:peco"
export EMOJI_CLI_USE_EMOJI=0

# load sheldon source
cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
sheldon_cache="$cache_dir/sheldon.zsh"
sheldon_toml="$HOME/.config/sheldon/plugins.toml"

# キャッシュがない、またはキャッシュが古い場合にキャッシュを作成
if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  mkdir -p $cache_dir
  sheldon source > $sheldon_cache
fi

source "$sheldon_cache" # load cached source file
unset cache_dir sheldon_cache sheldon_toml

# override fzf-git.sh
_fzf_git_fzf() {
fzf-tmux -p80%,60% -- \
  --layout=reverse --multi --height=50% --min-height=20 --border \
  --color='header:italic:underline' \
  --preview-window='right,50%,border-left' \
  --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' "$@"
}


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
# RPROMPT=$RPROMPT'$(git_super_status)'


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
setopt magic_equal_subst     # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる

setopt complete_in_word      # 語の途中でもカーソル位置で補完
setopt always_last_prompt    # カーソル位置は保持したままファイル名一覧を順次その場で表示

setopt extended_glob  # 拡張グロブで補完(~とか^とか。例えばless *.txt~memo.txt ならmemo.txt 以外の *.txt にマッチ)
setopt globdots # 明確なドットの指定なしで.から始まるファイルをマッチ

bindkey "^i" menu-complete   # 展開する前に補完候補を出させる(Ctrl-iで補完)


#
# fzf configurations
#
export FZF_DEFAULT_COMMAND="rg --smart-case --files --hidden --glob '!**/.git/*' --glob '!**/.venv/*' -uu "
export FZF_DEFAULT_OPTS='
  --prompt="[query] "
  --height=60%
  --margin=0,1
  --layout=reverse
  --inline-info
  --tiebreak=index
  --no-mouse
  --border
  --bind=ctrl-u:page-up,ctrl-d:page-down
  --bind=ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up
  --bind=ctrl-p:toggle-preview
'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
export FZF_CTRL_T_OPTS="
  --select-1 --exit-0
  --bind 'ctrl-l:execute(tmux splitw -h -- nvim {})'
  --preview 'bat -r :100 --color=always --style=header,grid {}'"

fzf-history-search() {
  LBUFFER="$(__fzf_history_search)"
  local ret=$?
  zle reset-prompt
  return $ret
}

__fzf_history_search() {
  BUFFER="$(history -nr 1 | fzf --query="$LBUFFER" --prompt="[history] " | sed 's/\\n/\n/')"
  local ret=$?
  CURSOR=$#BUFFER
  echo $BUFFER
  return $ret
}

zle -N fzf-history-search
bindkey '^r' fzf-history-search

fzf-file-search() {
  LBUFFER="${LBUFFER}$(__fzf_file_search)"
  local ret=$?
  zle reset-prompt
  return $ret
}

__fzf_file_search() {
  local selected=$(eval "$FZF_DEFAULT_COMMAND" | \
    fzf-tmux -p80%,90% --height="90%" \
      --multi \
      --prompt="[file search] " \
      --preview="bat --color=always --style=header,grid {1}" \
      --preview-window='down:60%:+{2}-4'
  )

  local ret=$?

  if [[ -n "$selected" ]]; then
    local eargs=""
    for line in ${(ps:\n:)selected}; do
        # echo $line
        eargs="${eargs}${line} "
    done
    echo "${eargs}"
  fi

  return $ret
}

zle -N fzf-file-search
bindkey '^o^f' fzf-file-search
bindkey '^of' fzf-file-search

fzf-directory-search() {
  LBUFFER="${LBUFFER}$(__fzf_directory_search)"
  local ret=$?
  zle reset-prompt
  return $ret
}

__fzf_directory_search() {
  local cmd="find . -type d -name '.git' -prune -o -type d -print"
  local selected=$(eval "$cmd" | \
      fzf-tmux -p80%,90% --height="90%" \
        --prompt="[directory search] " \
        --preview="tree -C {} | head -200" \
  )

  local ret=$?

  if [[ -n "$selected" ]]; then
    echo "${selected}"
  fi

  return $ret
}

zle -N fzf-directory-search
# bindkey '^[d' fzf-directory-search
bindkey '^o^d' fzf-directory-search
bindkey '^od' fzf-directory-search

fzf-text-search() {
  LBUFFER="${LBUFFER}$(__fzf_text_search)"
  local ret=$?
  zle reset-prompt
  return $ret
}

__fzf_text_search() {
  local rg_cmd="rg --smart-case --crlf --hidden --line-number --color=always --trim --glob '!**/.git/*' --glob '!**/.venv/*' --glob '!.gitignore' --glob '!**/*.lock' -uu"
  local initial_query="${*:-}"
  local selected=$(FZF_DEFAULT_COMMAND="$rg_cmd $(printf %q "$initial_query")" \
      fzf-tmux -p80%,90% --bind "ctrl-r:reload($rg_cmd {q})" --header "Press CTRL-R to reload" \
        --bind="ctrl-o:execute(tmux splitw -h -- nvim +/{q} {1} +{2})" \
        --height="90%" \
        --ansi --phony --multi \
        --prompt="[text search] " \
        --delimiter=":" \
        --preview="bat -H {2} --color=always --style=header,grid {1}" \
        --preview-window='down:60%:+{2}-4'
  )

  local ret=$?

  if [[ -n "$selected" ]]; then
    local eargs=""
    for line in ${(ps:\n:)selected}; do
        # echo $line
        local file_path=${${(@s/:/)line}[1]}
        # echo $file_path
        eargs="${eargs}${file_path} "
    done
    echo "${EDITOR} ${eargs}"
  fi

  return $ret
}

zle -N fzf-text-search
bindkey '^o^t' fzf-text-search
bindkey '^ot' fzf-text-search


fzf-ghq-search() {
  local selected=`ghq list | fzf --prompt="ghq search "`
  if [[ -n "$selected" ]]; then
    local target_dir="`ghq root`/$selected"
    cd $target_dir
    zle accept-line
  else
    zle reset-prompt
  fi
}

zle -N fzf-ghq-search
bindkey '^o^g' fzf-ghq-search
bindkey '^og' fzf-ghq-search

function fzf-kill() {
    for pid in `ps aux | fzf --height="80%" --multi --prompt="[kill?] " | awk '{ print $2 }'`
    do
        kill $pid
        echo "Killed ${pid}"
    done
}

function fzf-git-branch() {
    # branch_name=`git branch | fzf --prompt "[branch] " | head -n 1 | sed -e "s/^\*\s*//g"`
    # if [ -n "$target_dir" ]; then
    #     git switch $target_dir
    # fi
    _fzf_git_branches --no-multi | xargs git checkout
}

function github-star-import() {
  # git, curl, jq, fzf, ghq required
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
  echo $urls | fzf | ghq import
}


#
# Alias
#

alias reload_zsh='source ~/.zshrc'

alias '..'='cd ..'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias cdh='cd ${HOME}'

alias -g @g='| grep'
alias -g @l='| less -R'
alias -g @j='| jq -C'
alias -g @jl='| jq "." -C | less -R'
alias -g @h='| head'
alias -g @t='| tail'
alias -g @s='| sed'
alias -g @c='| less -XF'
alias -g @f='| fzf'
alias -g @em='| emojify'

alias ls='ls --color'
alias la='ls --color -lahF'
alias ll='ls --color -lhF'

alias rgl='(){rg -p $@ | less -R}'

alias -g gb='fzf-git-branch'
alias dockps='docker ps --format "{{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Command}}\t{{.RunningFor}}"'
alias dockex='docker exec -it `dps | fzf | cut -f 1` /bin/bash'

alias termi='terminator -l medium'
alias termis='terminator -l small'
alias termim='terminator -l medium'
alias termil='terminator -l large'

alias nv='nvim'

alias showtime='date & time'

alias di='dicto'
alias de='dicto -e'

# ghq & hub alias (with fzf)
alias ghq-cd='cd $(ghq root)/$(ghq list | fzf --prompt "[ghq src] ")'

alias hubb='hub browse $(ghq list | fzf --prompt "[browse src] " | cut -d "/" -f 2,3)'

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

# zplug
# export ZPLUG_HOME=~/.zplug
# export ZPLUG_CACHE_DIR=~/.cache/zplug
# if [ ! -d $ZPLUG_HOME ]; then
#   git clone https://github.com/zplug/zplug $ZPLUG_HOME
# fi

# if [ -f $ZPLUG_HOME/init.zsh ]; then
#   source $ZPLUG_HOME/init.zsh
#
#   # Plugins
#   zplug "zsh-users/zsh-completions", depth:1
#   zplug "zsh-users/zsh-syntax-highlighting", defer:2
#   zplug "b4b4r07/enhancd", use:init.sh, at:v2.2.4
#   zplug "b4b4r07/emoji-cli"
#   zplug "mrowa44/emojify", as:command, lazy:true
#   zplug "paulirish/git-open", as:plugin, lazy:true
#   zplug "junegunn/fzf-git.sh", use:fzf-git.sh
  # zplug 'zplug/zplug', hook-build:'zplug --self-manage'

  # Install plugins if there are plugins that have not been installed
  # if ! zplug check --verbose; then
  #   printf "Install? [y/N]: "
  #   if read -q; then
  #     echo; zplug install
  #   fi
  # fi
  #
  # # Then, source plugins and add commands to $PATH
  # zplug load


#
# Other Settings
#

setopt no_beep
setopt transient_rprompt
setopt auto_cd

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

  if command -v ibus-daemon > /dev/null; then
    if [ -z "$XMODIFIERS" ]; then
      export XMODIFIERS=@im=ibus
      ibus-daemon -drx
    else
      ibus-daemon -dr
    fi
  fi
fi

autoload -Uz compinit && compinit
