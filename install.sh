#!/bin/bash

# Ask for the administrator password upfront
# sudo -v

# Keep-alive: update existing `sudo` time stamp until finished
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
platform=$(uname)
pacman_args="--noconfirm --needed"

# list of files/folders to symlink in homedir
files="
config
xinitrc
xmodmap
Xresources
urxvt.xresources
crontab
su_crontab
bashrc
bash_profile
gitconfig
oh-my-zsh
gruvbox
zshrc
vimrc
tmux
tmux.conf
tmuxinator
gitconfig
gimp-2.8
mednafen
PyCharm40
themes
profile
pam_environment
xterm-256color-italic.terminfo
"
overrides="
zshrc_local
vimrc_local
tmux_local.conf
profile.local
gitconfig
"
# oh-my-zsh
# github repos to clone
GIT="
rupa/z
bkendzior/cowfiles
morhetz/gruvbox-contrib
"
PIP2="
grip
"
# powerline-status
# gems to install
GEMS="
tmuxinator
guard
bropages
sass
compass
"
NPM="
livedown
bower
gulp
yo
generator-meanjs
"
# install yaourt on Arch Linux
AUR="
package-query
yaourt
i3-gaps-git
dmenu2
compton
pulseaudio-ctl
google-chrome
thunar-dropbox
numix-icon-theme-git
ttf-hack
tty-clock-borderless
virtualbox-ext-oracle
gtk-theme-arc-git
fonts-meta-extended-lt
"
# dropbox
# dropbox-cli
# list of AUR programs to install on Arch Linux
YAOURT="
"
# atom-editor
PROGRAMS="
reflector
atool
evince
zathura
feh
gpicview
htop
w3m
rofi
imagemagick
scrot
cron
pavucontrol
lxappearance
pulseaudio
powerline
python2-pip
terminator
tree
gvim
tmux
build-essential
ctags
clang
cmake
ruby
npm
rxvt-unicode-patched
sl
cowsay
fortune-mod
ranger
thunar
highlight
rust
nodejs
mongodb
npm
"
#i3

# Returns 1 if program is installed and 0 otherwise
function program_installed {
    local return_=1

    type $1 >/dev/null 2>&1 || { local return_=0; }

    echo "$return_"
}

function link_dotfiles {
    # create dotfiles_old in homedir
    echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
    mkdir -p $olddir

    # change to the dotfiles directory
    cd $dir

    # move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the
    # homedir to any files in the ~/dotfiles directory specified in $files
    for file in $files; do
        if [[ -f $file || -d $file ]]; then
            echo ""
            if [[ -f ~/.$file || -d ~/.$file ]]; then
                echo "Moving : .$file (~/.$file -> $olddir/.$file)"
                rm -r $olddir/.$file
                mv ~/.$file $olddir/
            fi
            echo "Linking: $file ($dir/$file -> ~/.$file)"
            ln -s $dir/$file ~/.$file
        fi
    done
    for file in $overrides; do
        if [[ -f dotfile_overrides/$file ]]; then
            echo ""
            if [[ -f ~/.$file ]]; then
                echo "Moving : .$file (~/.$file -> $olddir/.$file)"
                rm -r $olddir/.$file
                mv ~/.$file $olddir/
            fi
            echo "Linking: $file ($dir/dotfile_overrides/$file -> ~/.$file)"
            ln -s $dir/dotfile_overrides/$file ~/.$file
        fi
    done
    # create symlink for bin directory
    if [[ ! -d ~/bin ]]; then
        ln -s ~/dotfiles/bin ~/bin
    fi
    if [[ ! -f ~/.z ]]; then
       touch ~/.z
    fi
}

# function install_all() {

# }

function install_AUR() {
    # install AUR programs if on Arch
    if [ $(program_installed pacman) == 1 ]; then
        echo -n "Do you want to upgrade/install from AUR? (y/n) "
        read response
        if [[ $response == 'y' ]] || [[ $response == 'Y' ]]; then
            echo "Creating ~/builds to hold AUR programs."
            mkdir -p ~/builds
            echo "Installing git if it's not installed."
            sudo pacman -Sq $pacman_args git
            echo "Installing base-devel if it's not installed."
            sudo pacman -Sq $pacman_args base-devel
            echo "Installing yaourt."
            for program in $AUR; do
                if [[ ! -d ~/builds/$program ]]; then
                    echo "Git cloning $program to ~/builds/$program ."
                    git clone https://aur.archlinux.org/$program.git ~/builds/$program
                    cd ~/builds/$program
                    # Problem here with still being root
                    makepkg -sri $pacman_args
                    cd $dir
                fi
            done
            echo "Installing AUR programs through yaourt."
            yaourt -Syua $pacman_args
            echo -n "Would you like to install all AUR programs? (y/n) "
            read response
            if [[ $response == 'y' ]] || [[ $response == 'Y' ]]; then
                echo "Installing AUR programs."
                for program in $YAOURT; do
                    # if [ $(program_installed $program) == 0 ]; then
                        yaourt -Sqa $pacman_args $program
                    # fi
                done
            fi
        fi
    fi
}

function install_programs() {
    if [ $(program_installed pacman) == 1 ]; then
        sudo pacman -Syuq
        for program in $PROGRAMS; do
            sudo pacman -Sq $pacman_args $program
        done
    elif [ $(program_installed apt-get) == 1 ]; then
        sudo apt-get update
        for program in $PROGRAMS; do
            sudo apt-get install $program
        done
    else
        echo "Cannot install tools, no compatible package manager."
    fi

    # cd into $dir
    cd $dir
}

function install_github() {
    # clone github repos
    for repo in $GIT; do
        git clone https://github.com/$repo
    done
}

function install_gems() {
    if [ $(program_installed ruby) == 1 ]; then
        for program in $GEMS; do
            gem install $program
        done
    fi
}

function install_rust_src () {
    if [[ $platform == 'Linux' ]]; then
        if [[ ! -d /usr/local/src/rust/ ]]; then
            echo "Cloning rust source into /usr/local/src/rust."
            sudo git clone https://github.com/rust-lang/rust.git /usr/local/src/rust
        else
            # Update if already installed
            echo "Updating rust source"
            cd /usr/local/src/rust
            sudo git pull
            cd $dir
        fi
    fi
}

function install_zsh() {
    # Test to see if zshell is installed.  If it is:
    if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
        # Clone my oh-my-zsh repository from GitHub only if it isn't already present
        if [[ ! -d $dir/oh-my-zsh/ ]]; then
            cd $dir
            git clone http://github.com/robbyrussell/oh-my-zsh.git
        fi
        # Set the default shell to zsh if it isn't currently set to zsh
        if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
            chsh -s $(which zsh)
        fi
    else
        # If zsh isn't installed, get the platform of the current machine
        platform=$(uname);
        # If the platform is Linux, try an apt-get to install zsh and then recurse
        if [[ $platform == 'Linux' ]]; then
            if [ $(program_installed apt-get) == 1 ]; then
                sudo apt-get install zsh
                install_zsh
            elif [ $(program_installed pacman) == 1 ]; then
                sudo pacman -S zsh
                install_zsh
            else
                echo "Cannot install zsh, no compatible package manager."
            fi
        # If the platform is OS X, tell the user to install zsh :)
        elif [[ $platform == 'Darwin' ]]; then
            echo "Please install zsh, then re-run this script!"
            exit
        fi
    fi

    # clone zsh-syntax-highlighting
    if [[ ! -d $dir/oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting $dir/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    fi
    # install gibo
    if [[ ! -d $dir/gibo ]]; then
        curl -L https://raw.github.com/simonwhitaker/gibo/master/gibo \
            -so ~/bin/gibo && chmod +x ~/bin/gibo && gibo -u
    fi
    # clone gibo completion
    if [[ ! -d $dir/oh-my-zsh/custom/plugins/gibo ]]; then
        if [[ -f $dir/gibo/gibo-completion.zsh ]]; then
            mkdir $dir/oh-my-zsh/custom/plugins/gibo
            ln -s $dir/gibo/gibo-completion.zsh $ZSH//custom/plugins/gibo/gibo.plugin.zsh
        fi
    fi
}

install_powerline_fonts() {
    cd $dir
    git clone http://github.com/powerline/fonts.git
    fonts/install.sh
    rm -rf fonts
}

function install_pip() {
    for program in $PIP2; do
        sudo pip2 install $program
    done
}

function install_npm() {
    for program in $NPM; do
        sudo npm install -g $program
    done
}

function fix_package_query() {
    echo "Removing old installs."
    if [ $(program_installed package-query) == 1 ]; then
        sudo pacman -Rdd package-query
    fi
    if [ $(program_installed yaourt) == 1 ]; then
        sudo pacman -Rdd yaourt
    fi
    echo "Upgrading system."
    sudo pacman -Syuq
    echo "Creating ~/builds to hold AUR programs."
    mkdir -p ~/builds
    echo "Installing git if it's not installed."
    sudo pacman -Sq $pacman_args git
    echo "Installing base-devel if it's not installed."
    sudo pacman -Sq $pacman_args base-devel
    echo "Installing package_query and yaourt."
    cd ~/builds
    echo "Removing old builds if they exist."
    rm -rf package-query
    rm -rf yaourt
    git clone https://aur.archlinux.org/package-query.git ~/builds/package-query
    cd ~/builds/package-query
    makepkg -sri $pacman_args
    git clone https://aur.archlinux.org/yaourt.git ~/builds/yaourt
    cd ~/builds/yaourt
    makepkg -sri $pacman_args
    cd $dir
}

function configure_system() {
    # If on arch, set time
    if [ $(program_installed pacman) == 1 ]; then
        timedatectl set-ntp true
    fi
    # Enable crontab
    systemctl enable cronie.service
}

function configure_freetype2() {
    sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
    sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
    sudo ln -s /etc/fonts/conf.avail/30-infinality-aliases.conf /etc/fonts/conf.d
}

function push_dotfiles() {
    cd $dir
    echo "Pushing dotfiles"
    git add -A
    git commit
    git push origin master
}

function update_dotfiles() {
    cd $dir
    git pull
}

function main() {
    echo "[1] Complete install and configuration"
    echo "[2] Push to github"
    echo "[3] Pull from github"
    echo "[4] Install dotfiles only"
    echo "[5] Install programs only"
    echo "[6] Configure system only"
    echo "[7] Install official repository programs only"
    echo "[8] Install AUR programs only"
    echo "[9] Install development sources only"
    echo "[10] Fix outdated package-query"
    echo "[11] Install gems only"
    echo "[12] Install github repositories only"
    echo "[13] Install npm packages only"
    echo "[0] Quit"
    echo ""
    echo "What would you like to do?"
    read response
    if [[ $response == "1" ]]; then
        link_dotfiles
        install_programs
        install_AUR
        install_github
        install_pip
        install_npm
        install_gems
        install_rust_src
        install_zsh
        install_powerline_fonts
        configure_system
        configure_freetype2
    elif [[ $response == "2" ]]; then
        push_dotfiles
    elif [[ $response == "3" ]]; then
        update_dotfiles
    elif [[ $response == "4" ]]; then
        link_dotfiles
        echo ""
        main
    elif [[ $response == "5" ]]; then
        install_programs
        install_AUR
        install_github
        install_pip
        install_npm
        install_gems
        echo ""
        main
    elif [[ $response == "6" ]]; then
        configure_system
        configure_freetype2
        echo ""
        main
    elif [[ $response == "7" ]]; then
        install_programs
        echo ""
        main
    elif [[ $response == "8" ]]; then
        install_AUR
        main
    elif [[ $response == "9" ]]; then
        install_rust_src
        main
    elif [[ $response == "10" ]]; then
        fix_package_query
        echo ""
        main
    elif [[ $response == "11" ]]; then
        install_gems
        echo ""
        main
    elif [[ $response == "12" ]]; then
        install_github
        echo ""
        main
    elif [[ $response == "13" ]]; then
        install_npm
        echo ""
        main
    fi
}

main
