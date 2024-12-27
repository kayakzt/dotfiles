#!/bin/zsh

# install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap homebrew/cask

# install via brew
brew bundle --file=./Brewfile
