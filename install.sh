#!/bin/bash
#
###############################################
#
# Initial setup script
#
# Option
#   -m : minimum install
#   -r : rootless install
#   -c : for cui environment install
#
# Dependent Package
#   * bash
#   * git
#   * curl
#

set -Ceu

echo "--- Install Script Start! ---"


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

get_password(){
  if ! ${password+:} false
  then
    printf "plz input password: "
    read -s password
    echo ""
  fi
}

#
# Environment set
#

detect_os() {
  if [ -e /etc/debian_version ] || [ -e /etc/debian_release ]; then
    if [ -e /etc/lsb-release ]; then
      OSNAME="ubuntu"
      UBUNTU_VERSION=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d "=" -f 2)
    else
      OSNAME="debian"
    fi
  elif [ -e /etc/redhat-release ]; then
    if [ -e /etc/oracle-release ]; then
      OSNAME="centos"
    else
      OSNAME="redhat"
    fi
  elif [ "$(uname)"  =  "Darwin" ]; then
    OSNAME="macos"
  else
    OSNAME="other"
  fi
}

detect_os

prepare_path() {
  if [ -z "${XDG_CONFIG_HOME+UNDEF}" ]; then
      CONF_PATH="${HOME}/.config"
  else
      CONF_PATH=$XDG_CONFIG_HOME
  fi
  DOT_PATH="${CONF_PATH}/dotfiles"
  WORKING_DIR=$(cd $(dirname $0); pwd)
  DOT_REPO="https://github.com/kaya-kzt/dotfiles"
}

prepare_path

# Aug Check
FLG_M=false
FLG_R=false
FLG_C=false

usage_exit() {
  echo "Usage: $0 [-m] [-r] [-c]" 1>&2
  exit 1
}

while getopts mrc OPT
do
  case $OPT in
    m) FLG_M=true ;;
    r) FLG_R=true ;;
    c) FLG_C=true ;;

    :|\?) usage_exit;;
  esac
done

echo -n "* OSNAME: "
echo $(colored $yellow "$OSNAME")

echo -n "* RUNTYPE: "
if $FLG_M; then
  echo -n $(colored $yellow "minimum, ")
fi
if $FLG_R; then
  echo -n $(colored $yellow "rootless, ")
fi
if $FLG_C; then
  echo -n $(colored $yellow "cui, ")
fi
echo " "

if ! $FLG_R; then
  get_password
fi

#
# Download dotfiles from github.com
#

if [ ! -e $DOT_PATH ]; then
    run mkdir -p $DOT_PATH
fi

git clone ${DOT_REPO} ${DOT_PATH}

#
# Add Repositories
#

if ( [ $OSNAME = "debian" ] || [ $OSNAME = "ubuntu" ] ) && ! $FLG_R; then
  echo "$password" | sudo -S echo ""
  # change apt repository, archive.ubuntu.jp -> JAIST
  sudo sed -i.bak -e "s%http://[^ ]\+%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list

  # add ppa repositories
  sudo apt install software-properties-common
  sudo -E add-apt-repository -y ppa:git-core/ppa
  sudo -E add-apt-repository -y ppa:ansible/ansible
  sudo -E add-apt-repository -y ppa:snwh/pulp
  sudo -E add-apt-repository -y ppa:tista/adapta
  # sudo -E add-apt-repository -y ppa:eosrei/fonts
  sudo -E add-apt-repository -y ppa:neovim-ppa/stable
fi

if ( [ $OSNAME = "centos" ] || [ $OSNAME = "redhat" ] ) && ! $FLG_R; then
  yum localinstall http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  yum localinstall http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-11.ius.centos6.noarch.rpm
fi

#
# Repository Updates + Upgrade
#

if ( [ $OSNAME = "debian" ] || [ $OSNAME = "ubuntu" ] ) && ! $FLG_R; then
  echo "$password" | sudo -S echo ""
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get dist-upgrade -y
  sudo apt-get -y autoremove
  sudo apt-get -y autoclean
fi

if ( [ $OSNAME = "oracle" ] || [ $OSNAME = "redhat" ] ) && ! $FLG_R; then
  yum check-update
  yum updade -y
  yum upgrade -y
  yum clean
fi


#
# Ubuntu setting changes
#

if [ $OSNAME = "ubuntu" ] && ! $FLG_R && ! $FLG_C; then
  echo "$password" | sudo -S echo ""
  # env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update
  if type "gsettings" > /dev/null 2>&1
  then
    gsettings set org.gnome.nautilus.preferences always-use-location-entry true
  fi
  sudo sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=10s/g' /etc/systemd/system.conf

  sudo apt-get install -y $(check-language-support -l ja)
  sudo apt-get install -y fcitx fcitx-mozc

  if $UBUNTU_VERSION="xenial"; then
    im-config -n fcitx

    if [ -e /usr/share/lightdm/lightdm.conf.d/50-no-guest.conf ]; then
      sudo sh -c 'printf "[SeatDefaults]\nallow-guest=false\n" >/usr/share/lightdm/lightdm.conf.d/50-no-guest.conf'
    fi
  else
    sudo apt-get install -y gnome-tweaks chrome-gnome-shell

    if type "gsettings" > /dev/null 2>&1
    then
      gsettings set org.gnome.mutter auto-maximize false
      gsettings set org.gnome.shell.app-switcher current-workspace-only true
    fi
  fi

  # Firewall setup
  sudo ufw default DENY
  sudo ufw allow ssh
  sudo ufw limit ssh
  sudo ufw enable
  sudo ufw reload
fi


#
# Basic Apps install
#

# preapre bin, src directories
run mkdir -p $HOME/dev
run mkdir -p $HOME/dev/bin
run mkdir -p $HOME/dev/src

if ( [ $OSNAME = "debian" ] || [ $OSNAME = "ubuntu" ] ) && ! $FLG_R; then
  echo "$password" | sudo -S echo ""
  sudo apt install -y build-essential \
    libssl-dev libreadline-dev zlib1g-dev \
    libappindicator1 \
    wget \
    git \
    zsh \
    xclip \
    gawk \
    terminator \
    python3-venv \
    ansible \
    openssh-server \
    silversearcher-ag \
    jq \
    exuberant-ctags \
    python-dev python-pip python3-dev python3-pip neovim \
    gufw

elif ( [ $OSNAME = "oracle" ] || [ $OSNAME = "redhat" ] ) && ! $FLG_R; then
  yum install -y wget \
    git \
    zsh \
    xclip \
    gawk \
    terminator \
    python3-dev \
    ansible \
    openssh-server \
    silversearcher-ag \
    jq
fi

# peco install ('go get' is not recommended)
install_peco() {
  PECO_VERSION=$(curl -sI https://github.com/peco/peco/releases/latest | awk -F'/' '/^Location:/{print $NF}')
  PECO_VERSION=`echo ${PECO_VERSION%\%*} | sed -e "s/[\r\n]\+//g"`
  echo $PECO_VERSION
  run wget https://github.com/peco/peco/releases/download/${PECO_VERSION}/peco_linux_amd64.tar.gz
  tar -zxvf peco_linux_amd64.tar.gz
  mv peco_linux_amd64/peco $HOME/dev/bin/peco
  chmod u+x $HOME/dev/bin/peco
  run rm peco_linux_amd64.tar.gz
  run rm -rf peco_linux_amd64
}
install_peco

# tmux install
install_tmux() {
  if ( [ $OSNAME = "debian" ] || [ $OSNAME = "ubuntu" ] ) && ! $FLG_R; then
    echo "$password" | sudo -S echo ""
    sudo apt-get install -y automake build-essential libevent-dev libncurses5-dev pkg-config
  elif ( [ $OSNAME = "oracle" ] || [ $OSNAME = "redhat" ] ) && ! $FLG_R; then
    yum install -y automake libevent-devel ncurses-devel
  fi

  if [ ! -d tmux ]; then
    git clone https://github.com/tmux/tmux.git
  fi

  cd ${WORKING_DIR}/tmux

  git checkout $(git tag | sort -V | tail -n 1)
  sh autogen.sh
  ./configure
  make
  echo "$password" | sudo -S echo ""
  sudo make install

  cd $WORKING_DIR
  rm -rf tmux

  # Install Tmux Package Manager
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

  # add execute previledges to tmux scripts
  chmod u+x $DOT_PATH/tmux.memory
  chmod u+x $DOT_PATH/tmux.loadaverage
}

# zsh install
install_zsh() {
  mkdir $HOME/local
  wget "http://sourceforge.net/projects/zsh/files/zsh/5.5.1/zsh-5.5.1.tar.gz/download"
  tar xzvf download
  cd zsh-5.5.1
  ./configure --prefix=$HOME/local --enable-multibyte --enable-locale
  make
  make install
  cd $WORKING_DIR
  rm -rf zsh-5.5.1
}

if ! $FLG_R; then
  if ! $FLG_C;  then
    install_tmux
  fi
else
  install_zsh
fi


#
# Developper Apps install
#

if ! $FLG_R && ! $FLG_M; then
  echo "$password" | sudo -S echo ""
  # install apps for building c++ code
  if ( [ $OSNAME = "debian" ] || [ $OSNAME = "ubuntu" ] ); then
    sudo apt install -y gdb valgrind strace ltrace \
    make cmake scons libhdf5-dev
  fi

  # pip default package update & package install
  pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs pip install -U --user
  pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs pip3 install -U --user

  pip install --user flake8 \
    wheel \
    jedi
  pip3 install --user flake8 \
    wheel \
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

  # goenv & setup
  echo "$password" | sudo -S echo ""
  export GOENV_ROOT=$HOME/.goenv
  git clone https://github.com/syndbg/goenv.git ~/.goenv
  export GOPATH=$HOME/dev
  export PATH=$PATH:$GOENV_ROOT/bin
  eval "$(goenv init -)"
  GO_VERSION=$(goenv install -l | tail -n 1 | tr -d ' ')
  goenv install $GO_VERSION
  goenv global $GO_VERSION
  go get github.com/motemen/ghq
  go get github.com/github/hub
  go get github.com/mdempsky/gocode # for deoplete-go

  # glide install
  GLIDE_VERSION=$(curl -sI https://github.com/Masterminds/glide/releases/latest | awk -F'/' '/^Location:/{print $NF}')
  GLIDE_VERSION=`echo ${GLIDE_VERSION%\%*} | sed -e "s/[\r\n]\+//g"`
  run wget https://github.com/Masterminds/glide/releases/download/"$GLIDE_VERSION"/glide-"$GLIDE_VERSION"-linux-amd64.tar.gz
  tar -zxvf glide-"$GLIDE_VERSION"-linux-amd64.tar.gz
  mv linux-amd64/glide $HOME/dev/bin/glide
  chmod u+x $HOME/dev/bin/glide
  run rm glide-"$GLIDE_VERSION"-linux-amd64.tar.gz
  run rm -rf linux-amd64

  # rustup (stable channel) setup
  echo "$password" | sudo -S echo ""
  curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -y --default-toolchain nightly
  # ru ncurl -L https://static.rust-lang.org/rustup.sh | sudo sh
  export PATH=$PATH:$HOME/.cargo/bin
  # cargo install --git "https://github.com/phildawes/racer.git"
  # cargo install --git "https://github.com/rust-lang-nursery/rustfmt.git"
  cargo install racer
  # cargo install rustfmt

  rustup component add rust-src

  # install rust stable channnel & default use
  rustup install stable
  rustup default stable
  rustup component add rust-src
  cargo install cargo-update
  cargo install cargo-script
  cargo install ripgrep

  # nvm setup
  # run curl -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash
  export NVM_DIR=$HOME/.nvm
  git clone https://github.com/creationix/nvm.git $NVM_DIR
  cd $NVM_DIR
  git checkout $(git tag | sort -V | tail -n 1) # set latest tag
  cd $WORKING_DIR

  # [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
  # nvm install --lts
  # nvm use --lts

  # rbenv setup
  git clone https://github.com/sstephenson/rbenv.git $HOME/.rbenv
  git clone https://github.com/rbenv/ruby-build.git $HOME/.rbenv/plugins/ruby-build
  export PATH=$PATH:$HOME/.rbenv/bin
  eval "$(rbenv init -)"
  RUBY_VERSION=$(rbenv install -l | grep -v -e ruby -e - | tail -n 1 | tr -d ' ')
  rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION
fi


#
# Themes & Icons & Fonts install
#

if ! $FLG_R && ! $FLG_M && ! $FLG_C; then
  run mkdir -p $HOME/.themes
  echo "$password" | sudo -S echo ""
  # Paper-Icon & Adapta-Gtk-Theme
  sudo apt-get install -y paper-icon-theme \
  paper-cursor-theme \
  adapta-gtk-theme

  git clone https://github.com/EliverLara/Ant.git ~/.themes/Ant-master
  git clone https://github.com/EliverLara/Ant-Bloody.git ~/.themes/Ant-Bloody-master

  # set customized noto sans cjk jp (Noto Sans CJK JP Kai)
  wget https://ja.osdn.net/downloads/users/9/9930/NSCJKaR.tar.xz
  tar xavf NSCJKaR.tar.xz && rm NSCJKaR.tar.xz
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
  printf "[Settings]\ngtk-theme-name = Ant-master\ngtk-icon-theme-name = Paper\n" \
  > $HOME/.config/gtk-3.0/settings.ini
fi


#
# App Setup
#

# zsh setup
if [ ! -e $HOME/.cache/shell/enhancd ]; then
    run mkdir -p $HOME/.config/shell/enhancd
fi

# neovim setup
if [ ! -e $HOME/.config/nvim ]; then
    run mkdir -p $HOME/.config/nvim
fi

# setup other files
if [ ! -e $CONF_PATH/fontconfig ]; then
    run mkdir $CONF_PATH/fontconfig
fi
if [ ! -e $CONF_PATH/peco ]; then
    run mkdir $CONF_PATH/peco
fi
if [ ! -e $CONF_PATH/terminator ]; then
    run mkdir $CONF_PATH/terminator
fi

# set symbolic link
run ln -snf $DOT_PATH/.zshenv $HOME/.zshenv
run ln -snf $DOT_PATH/.zshrc $HOME/.zshrc
run ln -snf $DOT_PATH/.zsh_logout $HOME/.zsh_logout
run ln -snf $DOT_PATH/tmux.conf $HOME/.tmux.conf
run ln -snf $DOT_PATH/tmux.memory $HOME/dev/bin/tmux.memory
run ln -snf $DOT_PATH/tmux.loadaverage $HOME/dev/bin/tmux.loadaverage
run ln -snf $DOT_PATH/.gitconfig $HOME/.gitconfig
run ln -snf $DOT_PATH/fonts.conf $CONF_PATH/fontconfig/fonts.conf
run ln -snf $DOT_PATH/nvim.init.vim $CONF_PATH/nvim/init.vim
run ln -snf $DOT_PATH/nvim.dein.toml $CONF_PATH/nvim/dein.toml
run ln -snf $DOT_PATH/nvim.dein_lazy.toml $CONF_PATH/nvim/dein_lazy.toml
run ln -snf $DOT_PATH/peco.config.json $CONF_PATH/peco/config.json
run ln -snf $DOT_PATH/.editorconfig $HOME/.editorconfig
run ln -snf $DOT_PATH/terminator_config $CONF_PATH/terminator/config


#
# Manual Processing for complete setup
#

cat <<-EOF

*** Setup processing completed!
There are some steps to finish setup.

* for System
1. import mozc.keymap.txt for using mozc tool.
2. change terminal color refered to terminal.color.txt (if u don't use a terminator).
3. launch Tweak-Tool, change Theme & Font (Roboto 10pt).
4. launch Tweak-Tool, set Gnome Extentions (see gnome_extentions.txt).
[option] if your host is on virtual, you should install below:
  * linux-tools-virtual
  * linux-cloud-tools-virtual
  * linux-tools-virtual-lts-{your os version}
  * linux-cloud-tools-virtual-lts-{your os version}

* for zsh
1. change default shell to zsh(chsh with no sudo).

* for Neovim
1. try :UpdateRemotePlugins & :CheckHealth to check plugin status
2. type :GoInstallBinaries to use vim-go

* End. Please reboot
EOF
