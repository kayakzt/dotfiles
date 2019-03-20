#!/bin/bash
#
###############################################
#
# Initial setup script
#
# Option
#     -m : minimum install
#     -r : rootless install
#     -c : for cui environment install
#
# Dependent Package
#     * bash
#     * git
#     * curl
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
    elif [ "$(uname)"    =    "Darwin" ]; then
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
FLG_V=false
FLG_H=false
USE_REPO_JAPAN=false
INSTALL_RUST=false

usage_exit() {
    echo "Usage: $0 [-m] [-r] [-c] [-v] [-h]" 1>&2
    exit 1
}

function yes_or_no(){
    PS3="Answer? "
    while true;do
        echo $(colored $cyan "$1")
        select answer in yes no;do
            case $answer in
                yes)
                    echo -e "tyeped yes.\n"
                    return 0
                    ;;
                no)
                    echo -e "tyeped no.\n"
                    return 1
                    ;;
                *)
                    echo -e "cannot understand your answer. plz input '1' or '2'.\n"
                    ;;
            esac
        done
    done
}

# argments processing
while getopts mrc OPT
do
    case $OPT in
        m) FLG_M=true ;;
        r) FLG_R=true ;;
        c) FLG_C=true ;;
        v) FLG_V=true ;;
        h) FLG_H=true ;;

        :|\?) usage_exit;;
    esac
done

# ask some questions to the user
yes_or_no "Do you wanna minimum install?" && FLG_M=true
yes_or_no "Do you wanna rootless install?" && FLG_R=true
yes_or_no "Is this a CUI environment?" && FLG_C=true
yes_or_no "Do you want to use repository in Japan?" && USE_REPO_JAPAN=true
yes_or_no "Do you want to install rust language?" && INSTALL_RUST=true
yes_or_no "Is the host VM?" && FLG_V=true && yes_or_no "Use xrdp for remote connection on Hyper-V?" && FLG_H=true

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
if $FLG_V; then
    echo -n $(colored $yellow "VM, ")
fi
if $FLG_H; then
    echo -n $(colored $yellow "hyper-v, ")
fi
if $USE_REPO_JAPAN; then
    echo -n $(colored $yellow "japan-repo, ")
fi
if $INSTALL_RUST; then
    echo -n $(colored $yellow "install_rust, ")
fi
echo " "

if ! $FLG_R; then
    get_password
fi

#
# Download dotfiles from github.com
#

if [ ! -e "$DOT_PATH" ]; then
        run mkdir -p "$DOT_PATH"
fi

git clone ${DOT_REPO} ${DOT_PATH}

#
# Add Repositories
#

if ( [ $OSNAME = "debian" ] || [ $OSNAME = "ubuntu" ] ) && ! $FLG_R; then
    echo "$password" | sudo -S echo ""

    if $USE_REPO_JAPAN; then
        # change apt repository to JAIST
        sudo sed -i.bak -e "s%http://[^ ]\+%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list
    fi

    # add ppa repositories
    sudo apt install software-properties-common
    sudo -E add-apt-repository -y ppa:git-core/ppa
    sudo -E add-apt-repository -y ppa:ansible/ansible
    sudo -E add-apt-repository -y ppa:snwh/pulp
    # sudo -E add-apt-repository -y ppa:tista/adapta
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
    # install fcitx if you need
    # sudo apt-get install -y fcitx fcitx-mozc

    sudo apt-get install -y gnome-tweaks chrome-gnome-shell

    if type "gsettings" > /dev/null 2>&1
    then
        gsettings set org.gnome.mutter auto-maximize false
        gsettings set org.gnome.shell.app-switcher current-workspace-only true
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
run mkdir -p "$HOME"/dev
run mkdir -p "$HOME"/dev/bin
run mkdir -p "$HOME"/dev/src

if ( [ $OSNAME = "debian" ] || [ $OSNAME = "ubuntu" ] ) && ! $FLG_R; then
    echo "$password" | sudo -S echo ""
    sudo apt install -y build-essential \
        libssl-dev \
        libreadline-dev \
        libappindicator1 \
        libffi-dev \
        libbz2-dev \
        libsqlite3-dev \
        zlib1g-dev \
        wget \
        git \
        zsh \
        xclip \
        gawk \
        terminator \
        ansible \
        openssh-server \
        silversearcher-ag \
        jq \
        exuberant-ctags \
        direnv \
        neovim \
        gufw
        # python3-venv \
        # python-dev python-pip python3-dev python3-pip \

elif ( [ $OSNAME = "oracle" ] || [ $OSNAME = "redhat" ] ) && ! $FLG_R; then
    sudo yum install -y wget \
        git \
        zsh \
        xclip \
        gawk \
        terminator \
        ansible \
        openssh-server \
        silversearcher-ag \
        jq
        # python3-dev \

    sudo yum install -y bzip2 \
        donebzip2-devel \
        libbz2-dev \
        openssl \
        openssl-devel \
        readline \
        readline-devel
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
    LATEST_TAG=$(curl -sSL "https://api.github.com/repos/tmux/tmux/releases/latest" | jq --raw-output .tag_name)

    git checkout "$LATEST_TAG"
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
    ./configure --prefix=$HOME/.local --enable-multibyte --enable-locale
    make
    make install
    cd $WORKING_DIR
    rm -rf zsh-5.5.1
}

# ripgrep install
install_rg() {
        # from https://gist.github.com/niftylettuce/a9f0a293289eb7274516bf2cb0455796
        REPO="https://github.com/BurntSushi/ripgrep/releases/download/"
        RG_LATEST=$(curl -sSL "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | jq --raw-output .tag_name)
        RELEASE="${RG_LATEST}/ripgrep-${RG_LATEST}-x86_64-unknown-linux-musl.tar.gz"

        TMPDIR=$(mktemp -d)
        cd $TMPDIR
        wget -O - ${REPO}${RELEASE} | tar zxf - --strip-component=1
        sudo mv rg /usr/local/bin/
        sudo mv doc/rg.1 /usr/local/share/man/man1/
        sudo mandb
        # sudo mv complete/rg.bash-completion /usr/share/bash-completion/completions/rg
        cd $WORKING_DIR
        rm -rf $TMPDIR
}

# install zsh to local in the rootless mode
if $FLG_R; then
    install_zsh
fi

# tmux and ripgrep are always installed to local
install_tmux
install_rg

#
# Config Setup
#

# zsh setup
if [ ! -e "$HOME/.cache/shell/enhancd" ]; then
        run mkdir -p "$HOME/.config/shell/enhancd"
fi

# neovim setup
if [ ! -e "$HOME/.config/nvim" ]; then
        run mkdir -p "$HOME/.config/nvim"
fi

# setup other files
if [ ! -e "$CONF_PATH/fontconfig" ]; then
        run mkdir "$CONF_PATH/fontconfig"
fi
if [ ! -e "$CONF_PATH/peco" ]; then
        run mkdir "$CONF_PATH/peco"
fi
if [ ! -e "$CONF_PATH/terminator" ]; then
        run mkdir "$CONF_PATH/terminator"
fi
if [ ! -e "$HOME/.zfunc" ]; then
        run mkdir "$HOME/.zfunc"
fi

# set symbolic link
run ln -snf "$DOT_PATH/.zshenv" "$HOME/.zshenv"
run ln -snf "$DOT_PATH/.zshrc" "$HOME/.zshrc"
run ln -snf "$DOT_PATH/.zsh_logout" "$HOME/.zsh_logout"
run ln -snf "$DOT_PATH/tmux.conf" "$HOME/.tmux.conf"
run ln -snf "$DOT_PATH/tmux.memory" "$HOME/dev/bin/tmux.memory"
run ln -snf "$DOT_PATH/tmux.loadaverage" "$HOME/dev/bin/tmux.loadaverage"
run ln -snf "$DOT_PATH/.gitconfig" "$HOME/.gitconfig"
run ln -snf "$DOT_PATH/fonts.conf" "$CONF_PATH/fontconfig/fonts.conf"
run ln -snf "$DOT_PATH/nvim.init.vim" "$CONF_PATH/nvim/init.vim"
run ln -snf "$DOT_PATH/nvim.dein.toml" "$CONF_PATH/nvim/dein.toml"
run ln -snf "$DOT_PATH/nvim.dein_lazy.toml" "$CONF_PATH/nvim/dein_lazy.toml"
run ln -snf "$DOT_PATH/peco.config.json" "$CONF_PATH/peco/config.json"
run ln -snf "$DOT_PATH/.editorconfig" "$HOME/.editorconfig"
run ln -snf "$DOT_PATH/terminator_config" "$CONF_PATH/terminator/config"


#
# Developper Apps install
#

if ! $FLG_R && ! $FLG_M; then
    echo "$password" | sudo -S echo ""
    # install apps for building c++ code + shellcheck
    if ( [ $OSNAME = "debian" ] || [ $OSNAME = "ubuntu" ] ); then
        sudo apt install -y gdb valgrind strace ltrace \
        make cmake scons libhdf5-dev shellcheck
        # for matplotlib build
        sudo apt install -y libfreetype6-dev pkg-config libpng-dev
    fi

    # set default directory for devolepment
    export my_dev_dir=~/dev

    # python
    # install pyenv
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    pyenv install "$(pyenv install --list | grep -v - | grep -v b | tail -1 | tr -d ' ')"
    pyenv global "$(pyenv install --list | grep -v - | grep -v b | tail -1 | tr -d ' ')"

    # install poetry
    curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python
    export PATH="$HOME/.poetry/bin:$PATH"
    poetry completions zsh > ~/.zfunc/_poetry

    # install python modules
    pip install wheel \
        flake8 \
        pep8 \
        autopep8 \
        yapf \
        mypy \
        pylint \
        wheel \
        jedi \
        numpy \
        scipy \
        scikit-learn \
        matplotlib \
        jupyter \
        seaborn \
        'python-language-server[all]' \
        pynvim

    # goenv & setup
    echo "$password" | sudo -S echo ""
    export GOENV_ROOT=$HOME/.goenv
    git clone https://github.com/syndbg/goenv.git ~/.goenv
    # export GOPATH=$HOME/dev
    export PATH=$PATH:$GOENV_ROOT/bin
    eval "$(goenv init -)"
    export GOENV_GOPATH_PREFIX=${my_dev_dir}/go # set GOPATH as GOENV_GOPATH_PREFIX/{go_version}
    GO_VERSION=$(goenv install -l | grep -v beta | grep -v rc | tail -1 | tr -d ' ')
    goenv install "$GO_VERSION"
    goenv global "$GO_VERSION"
    go get github.com/motemen/ghq
    go get github.com/github/hub
    go get github.com/mdempsky/gocode # for deoplete-go
    go get github.com/saibing/bingo # for lsp-server
    curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

    if $INSTALL_RUST; then
        # rustup (stable channel) setup
        echo "$password" | sudo -S echo ""
        curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -y --default-toolchain nightly
        # ru ncurl -L https://static.rust-lang.org/rustup.sh | sudo sh
        export PATH=$PATH:$HOME/.cargo/bin
        cargo install racer # racer must be installed under the nightly channel from 2.1

        # install rust stable channnel & default use
        rustup toolchain install stable
        rustup default stable
        rustup component add rustfmt
        rustup component add clippy
        rustup component add rust-src
        rustup component add rls rust-analysis rust-src # install RLS
        # rustup component add rls-preview rust-analysis rust-src
        cargo install cargo-update
        cargo install cargo-script
        # cargo install ripgrep
    fi

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
    # git clone https://github.com/sstephenson/rbenv.git $HOME/.rbenv
    # git clone https://github.com/rbenv/ruby-build.git $HOME/.rbenv/plugins/ruby-build
    # export PATH=$PATH:$HOME/.rbenv/bin
    # eval "$(rbenv init -)"
    # RUBY_VERSION=$(rbenv install -l | grep -v -e ruby -e - | tail -n 1 | tr -d ' ')
    # rbenv install $RUBY_VERSION
    # rbenv global $RUBY_VERSION
fi


#
# Themes & Icons & Fonts install
#

if ! $FLG_R && ! $FLG_C; then
    run mkdir -p "$HOME/.themes"
    echo "$password" | sudo -S echo ""
    # Paper-Icon & Adapta-Gtk-Theme
    sudo apt-get install -y paper-icon-theme \
    paper-cursor-theme

    git clone https://github.com/EliverLara/Ant.git ~/.themes/Ant
    git clone https://github.com/EliverLara/Ant-Bloody.git ~/.themes/Ant-Bloody
    git clone https://github.com/EliverLara/Ant-Dracula.git ~/.themes/Ant-Dracula

    # install fonts
    if ( [ $OSNAME = "debian" ] || [ $OSNAME = "ubuntu" ] ); then
        sudo apt-get install -y fonts-ipafont \
            fonts-ipafont-gothic \
            fonts-ipafont-mincho \
            fonts-noto-cjk \
            fonts-noto-color-emoji \
            fonts-roboto \
            fonts-takao \
            fonts-takao-gothic \
            fonts-takao-mincho
    fi

    # set customized noto sans cjk jp (Noto Sans CJK JP Kai)
    # wget https://ja.osdn.net/downloads/users/17/17406/NSCJKaR.tar.xz
    # tar xavf NSCJKaR.tar.xz && rm NSCJKaR.tar.xz
    # wget https://ja.osdn.net/downloads/users/10/10745/fonts.conf && \
    run mkdir -p ~/.local/share/fonts/
    # run mkdir -p ~/.config/fontconfig/ && \
    # run mv fonts.conf ~/.config/fontconfig/
    # run mv NSCJKaR/ ~/.local/share/fonts/

    # set Ricty Diminished for PowerLine
    git clone https://github.com/mzyy94/RictyDiminished-for-Powerline.git
    run mv RictyDiminished-for-Powerline/ ~/.local/share/fonts/
    fc-cache -fv

    # set gtk3.0 theme & icon
    if [ ! -e "$HOME/.config/gtk-3.0" ]; then
        run mkdir "$HOME/.config/gtk-3.0"
    fi
    printf "[Settings]\ngtk-theme-name = Ant\ngtk-icon-theme-name = Paper\n" \
    > "$HOME/.config/gtk-3.0/settings.ini"
fi

#
# VM setup
#

if $FLG_V; then
    if ( [ $OSNAME = "debian" ] || [ $OSNAME = "ubuntu" ] ); then
        sudo apt install -y linux-cloud-tools-common \
            linux-cloud-tools-generic \
            linux-cloud-tools-virtual \
            linux-cloud-tools-lowlatency
    fi
    if $FLG_H; then
            sudo apt install -y xrdp
            git clone https://github.com/Microsoft/linux-vm-tools.git ~/linux-vm-tools
            cd ~/linux-vm-tools/ubuntu/18.04/
            sudo chmod +x install.sh
            sudo ./install.sh
            cd "$WORKING_DIR"
            # rm -rf ~/linux-vm-tools
    fi
fi

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

if $FLG_H; then
    cat <<-EOF

reboot, then if you want to connect this VM with EnhancedSession on Hyper-V, don't remenber config below.
PS C:\> Set-VM -VMName <VMname> -EnhancedSessionTransportType HvSocket
PS C:\> (Get-VM -VMName <VMname>).EnhancedSessionTransportType

And, exchange xrdp keyboard layout (jp & us), see /etc/xrdp/xrdp_keyboard.ini to detect ini file name.
EOF
fi

exit 0
