# Environment Variables

export path=(/usr/local/bin(N-/) $path)

export GOROOT=/usr/local/go
export GOPATH=$HOME
export path=($GOROOT/bin(N-/) $GOPATH/bin(N-/) $path)

export path=($HOME/.cargo/bin(N-/) $path)
# export PATH=$PATH:"$HOME/.cargo/bin:$PATH"
export RUST_SRC_PATH=$HOME/src/rust-lang.org/rustc-1.17.0-src

export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

export path=($HOME/.rbenv/bin(N-/) $path)
eval "$(rbenv init -)"

export EDITOR=nvim

export path=(/usr/lib/git-core/(N-/) $path)

# History Settings
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
setopt histignorealldups
setopt EXTENDED_HISTORY
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_no_store
setopt hist_expand
setopt inc_append_history
# bindkey "^R" history-incremental-search-backward
# bindkey "^S" history-incremental-search-forward
