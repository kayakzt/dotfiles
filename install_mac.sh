#!/bin/zsh

# install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap homebrew/cask

# install via brew
brew bundle --file=./Brewfile

# install node v24 via mise
mise use --global node@24

# install latest python and go via mise
mise use --global python@latest
mise use --global go@latest
