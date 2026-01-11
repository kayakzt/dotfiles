#!/bin/zsh
set -Ceux

echo "--- Install Script Start! ---"

run() {
    "$@"
    result=$?

    if [ $result -ne 0 ]
    then
        echo -n $(colored $red "Failed: ")
        echo -n $(colored $cyan "$@")
        echo $(colored $yellow " [$PWD]")
        exit $result
    fi

    return 0
}

prepare_path() {
    CONF_PATH="${HOME}/.config"
    DOT_PATH="${CONF_PATH}/dotfiles"
    WORKING_DIR=$(pwd)
    DOT_REPO="https://github.com/kayakzt/dotfiles"
}

prepare_path

#
# Download dotfiles from github.com
#

if [ ! -e "$DOT_PATH" ]; then
        run mkdir -p "$DOT_PATH"
fi

git clone ${DOT_REPO} ${DOT_PATH}

#
# prepare bin, src directories
run mkdir -p "$HOME"/dev
run mkdir -p "$HOME"/dev/bin
run mkdir -p "$HOME"/dev/src
run mkdir -p "$HOME"/.local
run mkdir -p "$HOME"/.local/share

# zsh setup
if [ ! -e "$HOME/.cache/shell/enhancd" ]; then
        run mkdir -p "$HOME/.config/shell/enhancd"
fi

if [ ! -e "$HOME/.config/sheldon" ]; then
        run mkdir -p "$HOME/.config/sheldon"
fi

# neovim setup
if [ ! -e "$HOME/.config/nvim" ]; then
        run mkdir -p "$HOME/.config/nvim"
        run mkdir -p "$HOME/.config/nvim/lua"
        run mkdir -p "$HOME/.config/nvim/after/lsp"
        run mkdir -p "$HOME/.config/nvim/lua/plugins"
fi

if [ ! -e "$HOME/.config/efm-langserver" ]; then
        run mkdir -p "$HOME/.config/efm-langserver"
fi

# setup other files
if [ ! -e "$CONF_PATH/fontconfig" ]; then
        run mkdir "$CONF_PATH/fontconfig"
fi

if [ ! -e "$HOME/.zfunc" ]; then
        run mkdir "$HOME/.zfunc"
fi

if [ ! -e "$CONF_PATH/ghostty" ]; then
        run mkdir "$CONF_PATH/ghostty"
fi

# set symbolic link
run ln -snf "$DOT_PATH/.zshenv" "$HOME/.zshenv"
run ln -snf "$DOT_PATH/.zshrc" "$HOME/.zshrc"
run ln -snf "$DOT_PATH/.zsh_logout" "$HOME/.zsh_logout"
run ln -snf "$DOT_PATH/sheldon-config.toml" "$CONF_PATH/sheldon/plugins.toml"
run ln -snf "$DOT_PATH/tmux.conf" "$HOME/.tmux.conf"
run ln -snf "$DOT_PATH/tmux.memory" "$HOME/dev/bin/tmux.memory"
run ln -snf "$DOT_PATH/tmux.loadaverage" "$HOME/dev/bin/tmux.loadaverage"
run ln -snf "$DOT_PATH/.gitconfig" "$HOME/.gitconfig"
run ln -snf "$DOT_PATH/efm-langserver.yaml" "$CONF_PATH/efm-langserver/config.yaml"
run ln -snf "$DOT_PATH/.editorconfig" "$HOME/.editorconfig"
run ln -snf "$DOT_PATH/ghostty_config.txt" "$CONF_PATH/ghostty/config"

run ln -snf "$DOT_PATH/nvim/init.lua" "$CONF_PATH/nvim/init.lua"
run ln -snf "$DOT_PATH/nvim/plugins.manager.lua" "$CONF_PATH/nvim/lua/plugins/manager.lua"
run ln -snf "$DOT_PATH/nvim/plugins.ui.lua" "$CONF_PATH/nvim/lua/plugins/ui.lua"
run ln -snf "$DOT_PATH/nvim/plugins.util.lua" "$CONF_PATH/nvim/lua/plugins/util.lua"
run ln -snf "$DOT_PATH/nvim/vsnip" "$CONF_PATH/nvim/vsnip"
run ln -snf "$DOT_PATH/nvim/lsp" "$CONF_PATH/nvim/after/lsp"

# install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap homebrew/cask

# install via brew
brew bundle --file=./Brewfile

# install node v24 via mise
mise use --global node@24
npm install -g \
    npm-check-updates \
    yarn \
    markdownlint-cli \
    textlint

# install latest python and go via mise
mise use --global python@latest
mise use --global go@latest
