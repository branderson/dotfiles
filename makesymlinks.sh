#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
platform=$(uname)
# list of files/folders to symlink in homedir
files="
config
xinitrc
xmodmap 
Xresources 
crontab
bashrc 
zshrc 
oh-my-zsh 
vimrc 
vim 
tmux.conf
tmuxinator
gitconfig 
gimp-2.8 
mednafen 
PyCharm40 
themes 
profile
pam_environment"
configs="
xfce4/terminal
powerline"
# list of AUR programs to install on Arch Linux
AUR="
package-query
yaourt
"
YAOURT="
rxvt-unicode-patched
dmenu2
compton
pulseaudio-ctl
google-chrome
atom-editor
dropbox
dropbox-cli
thunar-dropbox
numix-icon-theme-git
ttf-hack
virtualbox-ext-oracle
gtk-theme-arc-git
"
PROGRAMS="
"

function program_installed {
    local return_=1

    type $1 >/dev/null 2>&1 || { local return_=0; }
    
    echo "$return_"
}

if [ $(program_installed cinnamon) == 1 ]; then
    files += "cinnamon"
fi

# install AUR programs if on Arch
if [ $(program_installed pacman) == 1 ]; then
    echo -n "Do you want to install AUR programs? (y/n) "
    read response
    if [ $response == y ] || [ $response == Y ]; then
        echo "Creating ~/builds to hold AUR programs."
        echo "Installing git if it's not installed."
        sudo pacman -S git
        echo "Installing base-devel if it's not installed."
        sudo pacman -S base-devel
        mkdir -p ~/builds
        for program in $AUR; do
            if [[ ! -d ~/builds/$program ]]; then 
                echo "Git cloning $program to ~/builds/$program ."
                git clone https://aur.archlinux.org/$program.git ~/builds/$program
                cd ~/builds/$program
                makepkg -sri
                cd $dir
            fi
        done
        for program in $YAOURT; do
            if [ $(program_installed $program) == 0 ]; then
                yaourt -S --force $program
            fi
        done
    fi
fi

#if [ $(program_installed xfce4) == 1 ]; then
#fi

##########

# create dotfiles_old in homedir
echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
mkdir -p $olddir
echo "done"

# change to the dotfiles directory
echo -n "Changing to the $dir directory ..."
cd $dir
echo "done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files
for file in $files; do
    echo "Moving any existing dotfiles from ~ to $olddir"
    mv ~/.$file ~/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
done

# move existing configs to old configs and make symlinks to dotfiles configs
# cd $dir/.config
# for config in $configs; do
#     echo "Moving any existing configs from ~/.config to $olddir/.config
#     mv ~/.

# create symlink for bin directory
if [[ ! -d ~/bin ]]; then 
    ln -s ~/dotfiles/bin ~/bin
fi

# clone Z
if [[ ! -d $dir/z ]]; then
    mkdir $dir/z
    git clone https://github.com/rupa/z $dir/z
fi

# Installation functions
install_tools () {
    if [ $(program_installed apt-get) == 1 ]; then
        sudo apt-get update
        sudo apt-get install i3
        sudo apt-get install feh
        sudo apt-get install imagemagick
        sudo apt-get install cron
        sudo apt-get install python2-pip
        sudo apt-get install terminator
        sudo apt-get install tree
        sudo apt-get install vim
        sudo apt-get install tmux
        sudo apt-get install build-essential
        sudo apt-get install ctags
        sudo apt-get install ruby
    elif [ $(program_installed pacman) == 1 ]; then
        sudo pacman -Syu
        timedatectl set-ntp true
        sudo pacman -S i3
        sudo pacman -S feh
        sudo pacman -S imagemagick
        sudo pacman -S cron
        sudo pacman -S pavucontrol
        sudo pacman -S pulseaudio
        sudo pacman -S python2-pip
        sudo pacman -S terminator
        sudo pacman -S tree
        sudo pacman -S gvim
        sudo pacman -S tmux
        sudo pacman -S build-essential
        sudo pacman -S ctags
        sudo pacman -S clang
        sudo pacman -S cmake
        sudo pacman -S ruby
        sudo pacman -S sl
        sudo pacman -S cowsay
        sudo pacman -S fortune-mod
        sudo pacman -S ranger
        sudo pacman -S highlight
    else 
        echo "Cannot install tools, no compatible package manager."
    fi
    # Enable crontab
    systemctl enable cronie.service
    if [ $(program_installed ruby) == 1 ]; then
        gem install tmuxinator
        gem install guard
        gem install bropages
    fi
}

install_rust_src () {
    if [[ $platform == 'Linux' ]]; then
        if [[ ! -d /usr/local/src/rust/ ]]; then 
            sudo git clone https://github.com/rust-lang/rust.git /usr/local/src/rust
        else
            echo "Rust source is installed"
        fi
    fi
}

install_zsh () {
    # Test to see if zshell is installed.  If it is:
    if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
        # Clone my oh-my-zsh repository from GitHub only if it isn't already present
        if [[ ! -d $dir/oh-my-zsh/ ]]; then
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
}

install_powerline_fonts() {
    git clone http://github.com/powerline/fonts.git
    fonts/install.sh
    rm -r -f fonts
    echo -n "Would you like to install powerline? (y/n) "
    read response
    if [ $response == y ] || [ $response == Y ]; then
        # TODO: Set up installing pip
        sudo pip2 install powerline-status
    fi
}

install_terminator () {
    # Test to see if terminator is installed. If it is:
    if [ -f /usr/bin/terminator ]; then
        if [ $(program_installed update-alternatives) == 1 ]; then
            # Set default terminal emulator
            echo "Select your prefered terminal emulator"
            sudo update-alternatives --config x-terminal-emulator
        fi
    else
        echo "Please install terminator, then re-run this script!"
        exit
    fi
}

prompt_installations() {
    # Guided install of all necessary programs and assets
    if [[ $platform == 'Linux' ]]; then
        echo -n "Would you like switch control with CapsLock? (y/n) "
        read response
        if [ $response == y ] || [ $response == Y ]; then
            if [[ ! -d ~/bin ]]; then 
                mkdir ~/bin
            fi
            cp nocaps.sh ~/bin/nocaps.sh
            echo "You will have to uncomment the function call in .bashrc."
        fi

        echo -n "Default install? (y/n) "
        read response
        if [ $response == y ] || [ $response == Y ]; then
            install_tools
            install_powerline_fonts
            install_zsh
            # install_rust_src
            install_terminator
        else
            echo -n "Would you like to install tools? (y/n) "
            read response
            if [ $response == y ] || [ $response == Y ]; then
                install_tools
            fi
            
            echo -n  "Would you like to install powerline fonts? (y/n) "
            read response
            if [ $response == y ] || [ $response == Y ]; then
                install_powerline_fonts
            fi

            echo -n "Would you like to install zsh? (y/n) "
            read response
            if [ $response == y ] || [ $response == Y ]; then
                install_zsh
            fi
            
            echo -n "Would you like to install rust src? (y/n) "
            read response
            if [ $response == y ] || [ $response == Y ]; then
                install_rust_src
            fi
            
            echo -n "Would you like to install terminator? (y/n) "
            read response
            if [ $response == y ] || [ $response == Y ]; then
                install_terminator
            fi
        fi
    fi
}

prompt_installations

# clone zsh-syntax-highlighting
if [[ ! -d $dir/oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting $dir/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi
