#!/bin/bash
#
###############################################
#
# Initial setup script for Ubuntu.
#
# Dependent Package
#   * bash
#   * git
#

set -Ceu


#
# Initialize
#

red=31
yellow=33
cyan=36

colored() {
  color=$1
  shift
  echo -e "\033[1;${color}m$@\033[0m"
}

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

#
# Environment set
#

echo -n "What's your name? (used by .gitconfig): "
read YOURNAME
echo -n "What's your email address? (used by .gitconfig): "
read USEREMAIL
echo "Your Email is ${USEREMAIL}"

echo "Hello, $YOURNAME [$USEREMAIL] !"
echo "Setup Processing Start."

# Declarations
if [ -z "${XDG_CONFIG_HOME+UNDEF}" ];then
    CONF_PATH="${HOME}/.config"
else
    CONF_PATH=$XDG_CONFIG_HOME
fi
DOT_PATH="${CONF_PATH}/dotfiles"
DOT_REPO="https://github.com/kaya-kzt/dotfiles"
UBUNTU_VERSION=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d "=" -f 2)

GO_VERSION="1.8.1"
PECO_VERSION="0.5.1"
RUST_VERSION="1.17.0"
NVM_VERSION="0.33.2"

#
# Download dotfiles
#

if [ ! -e $DOT_PATH ]; then
    run mkdir -p $DOT_PATH
fi

git clone ${DOT_REPO} ${DOT_PATH}

#
# Add Repositories
#

sudo add-apt-repository -y ppa:git-core/ppa
sudo apt-add-repository -y ppa:ansible/ansible
sudo add-apt-repository -y ppa:masterminds/glide
sudo add-apt-repository -y ppa:snwh/pulp
sudo add-apt-repository -y ppa:tista/adapta
sudo apt-add-repository -y ppa:eosrei/fonts
sudo add-apt-repository -y ppa:neovim-ppa/stable


#
# Repository Updates + Upgrade
#

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y


#
# Ubuntu setting changes
#

env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update
sudo sh -c 'printf "[SeatDefaults]\nallow-guest=false\n" >/usr/share/lightdm/lightdm.conf.d/50-no-guest.conf'
gsettings set org.gnome.nautilus.preferences always-use-location-entry true
sudo sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=10s/g' /etc/systemd/system.conf

im-config -n fcitx

# Firewall setup
sudo ufw enable
sudo ufw default DENY
sudo ufw allow ssh
sudo ufw limit ssh


#
# Basic Apps install
#

sudo apt install -y build-essential \
libssl-dev libreadline-dev zlib1g-dev \
libappindicator1 \
software-properties-common \
wget \
curl \
git \
zsh \
xclip \
xsel \
byobu \
python3-venv \
ansible \
openssh-server \
silversearcher-ag \
jq \
exuberant-ctags \
fonts-emojione-svginot \
python-dev python-pip python3-dev python3-pip neovim \
gufw

# peco install ('go get' is not recommended)
run wget https://github.com/peco/peco/releases/download/v"$PECO_VERSION"/peco_linux_amd64.tar.gz
tar -zxvf peco_linux_amd64.tar.gz
sudo mv peco_linux_amd64/peco /usr/local/bin/peco

# Google Chrome has to install manually,
# go to https://www.google.co.jp/chrome/browser/desktop/


#
# Developper Apps install
#

# preapre bin, src directories
run mkdir -p $HOME/bin
run mkdir -p $HOME/src

# install apps for building c++ code
sudo apt install -y gdb valgrind strace ltrace \
make cmake scons

# pip default package update & package install
sudo pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs sudo pip install -U
sudo pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs sudo pip3 install -U

sudo pip install flake8 \
jedi
sudo pip3 install flake8 \
jedi \
numpy \
scipy \
scikit-learn \
matplotlib \
jupyter \
seaborn \
neovim

# pyenv setup
# git clone https://github.com/yyuu/pyenv.git ~/.pyenv
# apt install -y python-virtualenv

# go-lang install
run wget https://storage.googleapis.com/golang/go"$GO_VERSION".linux-amd64.tar.gz
sudo tar -zxvf  go"$GO_VERSION".linux-amd64.tar.gz -C /usr/local/
sudo apt install -y glide
export GOPATH=$HOME
PATH="$PATH:/usr/local/go/bin"
go get github.com/motemen/ghq
go get github.com/github/hub

# Rust setup
run curl -L https://static.rust-lang.org/rustup.sh | sudo sh
cargo install --git "https://github.com/phildawes/racer.git"
cargo install --git "https://github.com/rust-lang-nursery/rustfmt"
if [ ! -e $HOME/src/rust-lang.org ]; then
    run mkdir -p $HOME/src/rust-lang.org
fi
wget https://static.rust-lang.org/dist/rustc-"$RUST_VERSION"-src.tar.gz
tar zxvf rustc-"$RUST_VERSION"-src.tar.gz
mv ./rustc-"$RUST_VERSION"-src $HOME/src/rust-lang.org/rustc-"$RUST_VERSION"-src
git init $HOME/src/rust-lang.org/rustc-"$RUST_VERSION"-src

# nvm setup
run curl -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash

# ruby setup
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

#
# Additional Package Install (Optonal)
#

# R install
#echo "deb http://cran.rstudio.com/bin/linux/ubuntu ${UBUNTU_VERSION}/" | sudo tee -a /etc/apt/sources.list
#sudo gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
#sudo gpg -a --export E084DAB9 | apt-key add -
#sudo apt-get update
#sudo apt-get install -y r-base r-base-dev


#
# Themes & Icons & Fonts install
#

# Paper-Icon & Adapta-Gtk-Theme
sudo apt-get install -y paper-icon-theme \
paper-gtk-theme \
paper-cursor-theme \
adapta-gtk-theme

# set customized noto sans cjk jp (Noto Sans CJK JP Kai)
wget https://ja.osdn.net/downloads/users/9/9930/NSCJKaR.tar.xz && \
tar xavf NSCJKaR.tar.xz && rm NSCJKaR.tar.xz && \
# wget https://ja.osdn.net/downloads/users/10/10745/fonts.conf && \
run mkdir -p ~/.local/share/fonts/
# run mkdir -p ~/.config/fontconfig/ && \
# run mv fonts.conf ~/.config/fontconfig/
run mv NSCJKaR/ ~/.local/share/fonts/

# set Ricty Diminished for PowerLine
git clone https://github.com/mzyy94/RictyDiminished-for-Powerline.git
run mv RictyDiminished-for-Powerline/  ~/.local/share/fonts/
fc-cache -fv

# set gtk3.0 theme & icon
if [ ! -e $HOME/.config/gtk-3.0 ]; then
    run mkdir $HOME/.config/gtk-3.0
fi
printf "[Settings]\ngtk-theme-name = Adapta\ngtk-icon-theme-name = Paper\n" \
> $HOME/.config/gtk-3.0/settings.ini


#
# App Setup
#

# zsh setup
if [ ! -e $HOME/.cache/shell/enhancd ]; then
    run mkdir -p $HOME/.cache/shell/enhancd
fi

# zplug install
# curl -sL zplug.sh/installer | zsh
curl -sL --proto-redir -all,https https://zplug.sh/installer | zsh

# neovim setup
if [ ! -e $HOME/.config/nvim ]; then
    run mkdir -p $HOME/.config/nvim
fi

# git setup
sudo apt install -y libgnome-keyring-dev
sudo make -C /usr/share/doc/git/contrib/credential/gnome-keyring
sudo chmod 0755 /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring
# run cp /usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring ~/bin/git-credential-gnome-keyring
run sed -i -e "s/:GITNAME:/${YOURNAME}/" $DOT_PATH/.gitconfig
run sed -i -e "s/:GITEMAIL:/${USEREMAIL}/" $DOT_PATH/.gitconfig

# setup other files
if [ ! -e $CONF_PATH/fontconfig ]; then
    run mkdir $CONF_PATH/fontconfig
fi
if [ ! -e $CONF_PATH/peco ]; then
    run mkdir $CONF_PATH/peco
fi

# set symbolic link
run ln -snf $DOT_PATH/.zshenv $HOME/.zshenv
run ln -snf $DOT_PATH/.zshrc $HOME/.zshrc
run ln -snf $DOT_PATH/.zsh_logout $HOME/.zsh_logout
run ln -snf $DOT_PATH/.gitconfig $HOME/.gitconfig
run ln -snf $DOT_PATH/fonts.conf $CONF_PATH/fontconfig/fonts.conf
run ln -snf $DOT_PATH/nvim.init.vim $CONF_PATH/nvim/init.vim
run ln -snf $DOT_PATH/nvim.dein.toml $CONF_PATH/nvim/dein.toml
run ln -snf $DOT_PATH/nvim.dein_lazy.toml $CONF_PATH/nvim/dein_lazy.toml
run ln -snf $DOT_PATH/peco.config.json $CONF_PATH/peco/config.json
run ln -snf $DOT_PATH/.editorconfig $HOME/.editorconfig


#
# install package for VM
#

# for Ubuntu
sudo apt-get install -y linux-tools-virtual-lts-${UBUNTU_VERSION} \
linux-cloud-tools-virtual-lts-${UBUNTU_VERSION} \
linux-tools-virtual \
linux-cloud-tools-virtual
# cat /var/log/boot.log | grep Hyper


#
# Cleanup
#

sudo apt-get -y autoremove
sudo apt-get -y autoclean

run rm peco_linux_amd64.tar.gz
run rm -rf peco_linux_amd64
run rm go"$GO_VERSION".linux-amd64.tar.gz
run rm rustc-"$RUST_VERSION"-src.tar.gz


#
# Manual Processing for complete setup
#

printf "\n\n***\nSetup processing completed!\n"
printf "There are some manual operations to finish setup.\n"

printf "\n* for System\n"
printf "1. import mozc.keymap.txt using mozc tool.\n"
printf "2. change terminal color refered to terminal.color.txt.\n"
printf "3. launch Tweak-Tool, change Theme & Font.\n"
printf "4. launch Tweak-Tool, set Gnome Extentions.\n"

printf "\n* for zsh\n"
printf "1. change default shell to zsh.\n"

printf "\n* for Neovim\n"
printf "1. if deoplete error occured, try :UpdateRemotePlugins command, or g:python3_host_prog in init.vim"

printf "\n* End. Please reboot\n"
