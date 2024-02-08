#!/bin/bash

# TODO: Fix audio issues specific to my motherboard (put this in install_local.sh)
# Update /usr/share/alsa-card-profile/mixer/paths/analog-output-lineout.conf
# https://forum.level1techs.com/t/speaker-audio-not-working-until-alsamixer-headphone-volume-manually-raised/177397/51
# [Element Headphone]
#- switch = off
#- volume = off
#+ switch = mute
#+ volume = merge

# TODO: Install gruvbox themes
# cd dotfiles && git submodule update --init
# cd ~/dotfiles/dependencies && git clone https://github.com/ohmyzsh/ohmyzsh
# cd ~/dotfiles/dependencies && git clone https://github.com/gruvbox-community/gruvbox-contrib
# cd ~/dotfiles/dependencies && git clone https://github.com/morhetz/gruvbox

# TODO: Customize lightdm
# Move some wallpaper assets into this repo
# cp ~/dotfiles/assets/lightdm-background.png /usr/share/endeavouros/backgrounds/custom-wallpaper.png
# sudo sed --in-place=.backup 's/background=/usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png/background=/usr/share/endeavouros/backgrounds/custom-wallpaper.png/g' /etc/lightdm/slick-greeter.conf

# TODO: Set the primary display
# display-setup-script=xrandr --output DP-4 --primary
# sudo sed --in-place=.backup 's/#display-setup-script=/display-setup-script=xrandr --output DP-4 --primary/g' /etc/lightdm/lightdm.conf

dir=~/dotfiles/config            # dotfiles directory
platform=$(uname)
pacman_args="--noconfirm --needed"
restart_needed=0

# Files and directories to link to home directory
home_files="
zshrc
zsh_functions
zshrc_local
profile
profile.local
tmux.conf
tmux
gtkrc-2.0.mine
themes
icons
"
# Directories under ~/.config
configs="
nvim
i3
alacritty
dunst
conky
rofi
gtk-3.0
powerline
"
arch="
"
apt=""
aur="
"

if [[ -f ~/dotfiles/install-arch.global ]]; then
    arch="$(<~/dotfiles/install-arch.global)"
fi
if [[ -f ~/dotfiles/install-aur.global ]]; then
    aur="$(<~/dotfiles/install-aur.global)"
fi
if [[ -f ~/dotfiles/install-apt.global ]]; then
    apt="$(<~/dotfiles/install-apt.global)"
fi
if [[ -f ~/dotfiles/install-arch.local ]]; then
    arch_overrides="$(<~/dotfiles/install-arch.local)"
    printf -v arch "${arch}\n${arch_overrides}"
fi
if [[ -f ~/dotfiles/install-aur.local ]]; then
    aur_overrides="$(<~/dotfiles/install-aur.local)"
    printf -v aur "${aur}\n${aur_overrides}"
fi
if [[ -f ~/dotfiles/install-apt.local ]]; then
    apt_overrides="$(<~/dotfiles/install-apt.local)"
    printf -v apt "${apt}\n${apt_overrides}"
fi

# Returns 1 if program is installed and 0 otherwise
function program_installed {
    local return_=1

    type $1 >/dev/null 2>&1 || { local return_=0; }

    echo "$return_"
}

function link_dotfiles {
    # change to the dotfiles directory
    cd $dir
    echo ""

    # Check if existing file in homedir and warn if so, otherwise create symlinks from the
    # files in the dotfiles directory specified in $files to the homedir
    for file in $home_files; do
        if [[ -f $file || -d $file ]]; then
            if [[ -f ~/.$file || -d ~/.$file ]]; then
                echo "Skipping: $file because ~/.$file already exists"
            else
                echo "Linking: $file ($dir/$file -> ~/.$file)"
                ln -s $dir/$file ~/.$file
            fi
        fi
    done
    for file in $configs; do
        if [[ -f $file || -d $file ]]; then
            if [[ -f ~/.config/$file || -d ~/.config/$file ]]; then
                echo "Skipping: $file because ~/.config/$file already exists"
            else
                echo "Linking: $file ($dir/$file -> ~/.config/$file)"
                ln -s $dir/$file ~/.config/$file
            fi
        fi
    done
    cd - > /dev/null
}

function install_aur() {
    # install AUR programs if on Arch
    if [ $(program_installed yay) == 1 ]; then
        echo -n "Do you want to upgrade/install from AUR? (y/n) "
        read response
        if [[ $response == 'y' ]] || [[ $response == 'Y' ]]; then
            echo "Installing AUR programs through yay."
            yay -Syua $pacman_args
            echo -n "Would you like to install all AUR programs? (y/n) "
            read response
            if [[ $response == 'y' ]] || [[ $response == 'Y' ]]; then
                echo "Installing AUR programs."
                for program in $aur; do
                    if [ $(program_installed $program) == 0 ]; then
                        yay -Sqa $pacman_args $program
                    fi
                done
            fi
        fi
    fi
}

function install_programs() {
    if [ $(program_installed pacman) == 1 ]; then
        sudo pacman -Syuq
        for program in $arch; do
            if [ $(program_installed $program) == 0 ]; then
                sudo pacman -Sq $pacman_args $program
            fi
        done
    elif [ $(program_installed apt-get) == 1 ]; then
        sudo apt-get update
        for program in $apt; do
            if [ $(program_installed $program) == 0 ]; then
                sudo apt-get install $program
            fi
        done
    else
        echo "Cannot install tools, no compatible package manager."
    fi
}

function setup_zsh() {
    echo
    if [[ $(program_installed zsh) == 1 && "$SHELL" != "$(which zsh)" ]]; then
        echo -n "Would you like to set zsh as your default shell? (y/n) "
        read response
        if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
            echo "Setting zsh as default shell"
            chsh -s /usr/bin/zsh
        fi
    fi
}

function setup_system_configs() {
    setup_zsh
    echo
    if [ $(program_installed lightdm) == 1 ]; then
        echo "Enabling numlock at startup"
        original=`cat /etc/lightdm/lightdm.conf` >> /dev/null
        sudo sed --in-place=.backup 's/#greeter-setup-script=/greeter-setup-script=\/usr\/bin\/numlockx on/g' /etc/lightdm/lightdm.conf
        edited=`cat /etc/lightdm/lightdm.conf` >> /dev/null
        diff=`diff <(echo "$original") <(echo "$edited")`
        if [[ "$diff" != '' ]]; then
            echo "$diff"
            restart_needed=1
        else
            echo "No changes were made"
        fi
        echo
    fi
    if [[ -f /usr/share/xdg-desktop-portal/portals/gtk.portal && $(program_installed i3) == 1 ]]; then
        echo "Enabling xdg-desktop-portal-gtk in i3 (needed for Steam)"
        original=`cat /usr/share/xdg-desktop-portal/portals/gtk.portal` >> /dev/null
        sudo sed --in-place=.backup 's/^UseIn=gnome$/UseIn=gnome;i3/g' /usr/share/xdg-desktop-portal/portals/gtk.portal
        edited=`cat /usr/share/xdg-desktop-portal/portals/gtk.portal` >> /dev/null
        diff=`diff <(echo "$original") <(echo "$edited")`
        if [[ "$diff" != '' ]]; then
            echo "$diff"
            restart_needed=1
        else
            echo "No changes were made"
        fi
        echo
    fi
}

function setup_samba() {
    echo
    echo -n "What samba host would you like to configure? "
    read samba_host
    if [[ "$samba_host" != '' ]]; then
        echo -n "Would you like to configure samba credentials? (y/n) "
        read response
        if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
            [[ ! -d "/etc/samba" ]] && sudo mkdir /etc/samba
            [[ ! -d "/etc/samba/credentials" ]] && sudo mkdir /etc/samba/credentials
            if [[ -d "/etc/samba/credentials" ]]; then
                echo
                echo -n "username: "
                read username
                echo -n "password: "
                read -s password
                echo
                echo "Writing config to /etc/samba/credentials/$samba_host"
                printf "username=$username\npassword=$password" | sudo tee "/etc/samba/credentials/$samba_host" >> /dev/null
                unset username
                unset password
            fi
        fi
        echo
        echo "Add lines to /etc/fstab for each share to mount:"
        echo "//{SAMBA_HOST_IP}/{SAMBA_SHARE}  /mnt/{MOUNT_DIR}    cifs    _netdev,nofail,uid=`id -u`,gid=`id -g`,credentials=/etc/samba/credentials/$samba_host    0   0"
    fi
    echo
    unset samba_host
}

function fix_package_query() {
    if [ $(program_installed pacman) == 1 ]; then
        echo "Removing old installs."
        if [ $(program_installed package-query) == 1 ]; then
            sudo pacman -Rdd package-query
        fi
        if [ $(program_installed pacaur) == 1 ]; then
            # TODO: Will this work?
            sudo pacman -Rdd pacaur
        fi
        echo "Upgrading system."
        sudo pacman -Syuq
        echo "Creating ~/builds to hold AUR programs."
        mkdir -p ~/builds
        echo "Installing git if it's not installed."
        sudo pacman -Sq $pacman_args git
        echo "Installing base-devel if it's not installed."
        sudo pacman -Sq $pacman_args base-devel
        echo "Installing package_query and pacaur."
        cd ~/builds
        echo "Removing old builds if they exist."
        rm -rf package-query
        rm -rf pacaur
        git clone https://aur.archlinux.org/package-query.git ~/builds/package-query
        cd ~/builds/package-query
        makepkg -sri $pacman_args
        git clone https://aur.archlinux.org/pacaur.git ~/builds/pacaur
        cd ~/builds/pacaur
        makepkg -sri $pacman_args
        cd $dir
    fi
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

function local_install() {
    if [ -f "~/dotfiles/install_local.sh" ]; then
        ~/dotfiles/install_local.sh
    fi
}

function main() {
    if [[ $(program_installed pacman) == 1 ]]; then
        echo "[complete] Complete install (dotfiles, pacman, aur, system-configs, samba)"
    elif [[ $(program_installed apt) == 1 ]]; then
        echo "[complete] Complete install (dotfiles, apt, system-configs, samba)"
    fi
    echo "[push] Push to github"
    echo "[pull] Pull from github"
    echo "[dotfiles] Install dotfiles only"
    if [[ $(program_installed pacman) == 1 ]]; then
        echo "[programs] Install programs (pacman, aur) only"
    elif [[ $(program_installed apt) == 1 ]]; then
        echo "[programs] Install programs (apt) only"
    fi
    if [[ $(program_installed pacman) == 1 ]]; then
        echo "[programs-official] Install official repository programs (pacman) only"
        echo "[aur-only] Install AUR programs only"
        echo "[package-query] Fix outdated package-query"
    fi
    echo "[system-configs] Set up system configs only"
    echo "[samba] Set up samba credentials only"
    echo "[0] Quit"
    echo ""
    echo "What would you like to do?"
    read response
    if [[ $response == "complete" ]]; then
        link_dotfiles
        install_programs
        install_aur
        setup_system_configs
        setup_samba
    elif [[ $response == "push" ]]; then
        push_dotfiles
    elif [[ $response == "pull" ]]; then
        update_dotfiles
    elif [[ $response == "dotfiles" ]]; then
        link_dotfiles
        echo ""
        main
    elif [[ $response == "programs" ]]; then
        install_programs
        install_aur
        echo ""
        main
    elif [[ $response == "programs-official" ]]; then
        install_programs
        echo ""
        main
    elif [[ $response == "aur-only" ]]; then
        install_aur
        echo ""
        main
    elif [[ $response == "package-query" ]]; then
        fix_package_query
        echo ""
        main
    elif [[ $response == "system-configs" ]]; then
        setup_system_configs
        echo ""
        main
    elif [[ $response == "samba" ]]; then
        setup_samba
        echo ""
        main
    fi
}

main
