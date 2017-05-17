# Environment Variables
export path=(/usr/local/bin(N-/) $HOME/bin(N-/) $path)

# goenv & go
export GOENV_ROOT=$HOME/.goenv
export GOPATH=$HOME
export path=($GOENV_ROOT/bin(N-/) $path)
if command -v goenv > /dev/null; then
  eval "$(goenv init -)"
fi

# rustup & rust
export path=($HOME/.cargo/bin(N-/) $path)
export RUST_ROOT=$(rustc --print sysroot)
export RUST_SRC_PATH=${RUST_ROOT}/lib/rustlib/src/rust/src/

export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" --no-use # This loads nvm

export path=($HOME/.rbenv/bin(N-/) $path)
if command -v rbenv > /dev/null; then
  eval "$(rbenv init - --no-rehash)"
fi

export EDITOR=nvim

export path=(/usr/lib/git-core/(N-/) $path)

# History Settings
HISTSIZE=1000
SAVEHIST=10000
HISTFILE=${HOME}/.zsh_history
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
