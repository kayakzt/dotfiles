# Environment Variables

# # proxy settings
# export http_proxy=
# export https_proxy=$http_proxy
# export HTTP_PROXY=$http_proxy
# export HTTPS_PEOXY=$http_proxy
# export no_proxy=
# export NO_PROXY=$no_proxy

# basic path
export my_dev_dir=~/dev
export path=(${my_dev_dir}/bin(N-/) $path)
export path=(/opt/local/bin(N-/) $path)
export path=(~/.local/bin(N-/) $path)
export path=(/snap/bin(N-/) $path)

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export path=($PYENV_ROOT/bin(N-/) $path)
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi
export path=($HOME/.poetry/bin(N-/) $path)
# if [[ -n $VIRTUAL_ENV && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
#     source "${VIRTUAL_ENV}/bin/activate"
# fi

# goenv & go
export GOENV_ROOT=$HOME/.goenv
export GOENV_GOPATH_PREFIX=${my_dev_dir}/go # set GOPATH as GOENV_GOPATH_PREFIX/{go_version}
# export GOENV_DISABLE_GOPATH=1 # disable GOPATH management by goenv
export path=($GOENV_ROOT/bin(N-/) $path)
if command -v goenv > /dev/null; then
    eval "$(goenv init -)"
fi
# export GOPATH=${my_dev_dir}
export path=($GOPATH/bin(N-/) $path)

# rustup & rust
export path=($HOME/.cargo/bin(N-/) $path)
if command -v rustc > /dev/null; then
    export RUST_ROOT=$(rustc --print sysroot)
    export RUST_SRC_PATH=${RUST_ROOT}/lib/rustlib/src/rust/src/
fi

# nvm & node path
export NVM_DIR=$HOME/.nvm
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm() { # pesuedo nvm function
    unset -f nvm
    source "${NVM_DIR}/nvm.sh"
    nvm "$@"
}

NODE_VERSION=v$(cat ${NVM_DIR}/alias/default) # set 'nvm alias default vX.Y.Z'
NODE_PATH=${NVM_DIR}/versions/node/$NODE_VERSION/bin
MANPATH=${NVM_DIR}/versions/node/$NODE_VERSION/share/man:$MANPATH
export path=($NODE_PATH(N-/) $path)

# rbenv
export path=($HOME/.rbenv/bin(N-/) $path)
if command -v rbenv > /dev/null; then
    eval "$(rbenv init - --no-rehash)"
fi

# other settings

export EDITOR=nvim
export PAGER=less

export path=(/usr/lib/git-core/(N-/) $path)
fpath=( ~/.zfunc "${fpath[@]}" )

# History Settings
HISTSIZE=1000
SAVEHIST=10000
HISTFILE=${HOME}/.zsh_history
setopt histignorealldups
setopt EXTENDED_HISTORY
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_no_store
setopt hist_expand
setopt inc_append_history
