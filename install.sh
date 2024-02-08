#!/bin/bash

# =================================================================================================
#
# This program provides helpful tools for initializing a new system based on my personal dotfiles.
# It aims to provide a core set of common configs across a number of tools I use, while remaining
# flexible to a variety of deployment scenarios with different requirements.
#
# To support flexibility, this installer reads from a set of package lists. These are stored in the
# `packages` directory, in `[arch,aur,apt].[global,local]` files, corresponding to the repository
# and scope of the package.
#
# To add an Arch User Repository (AUR) package to your local config, `touch ./packages/aur.local`
# and add the package name, one per line. These will be included when installing packages from their
# respective installer commands.
#
#
# =================================================================================================

# TODO: Put installer script in path
#
# TODO: Install gruvbox themes
# cd dotfiles && git submodule update --init
# mkdir ~/dotfiles/config/themes ~/dotfiles/config/icons
# cp -r ~/dotfiles/dependencies/Gruvbox-GTK-Theme/themes/* ~/dotfiles/config/themes
# cp -r ~/dotfiles/dependencies/Gruvbox-GTK-Theme/icons/* ~/dotfiles/config/icons

# TODO: Customize lightdm
# Move some wallpaper assets into this repo
# cp ~/dotfiles/assets/lightdm-background.png /usr/share/endeavouros/backgrounds/custom-wallpaper.png
# sudo sed --in-place=.backup 's/background=/usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png/background=/usr/share/endeavouros/backgrounds/custom-wallpaper.png/g' /etc/lightdm/slick-greeter.conf

# TODO: Restart needed

dir=~/dotfiles                      # dotfiles repository directory
config_dir="$dir"/config
packages_dir="$dir"/packages
platform=$(uname)
pacman_args="--noconfirm --needed"
restart_needed=0

source "$dir"/functions.sh

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

function load_package_lists() {
    if [[ -f "$packages_dir"/arch.global ]]; then
        arch="$(<"$packages_dir"/arch.global)"
    fi
    if [[ -f "$packages_dir"/aur.global ]]; then
        aur="$(<"$packages_dir"/aur.global)"
    fi
    if [[ -f "$packages_dir"/apt.global ]]; then
        apt="$(<"$packages_dir"/apt.global)"
    fi
    if [[ -f "$packages_dir"/arch.local ]]; then
        arch_overrides="$(<"$packages_dir"/arch.local)"
        printf -v arch "${arch}\n${arch_overrides}"
    fi
    if [[ -f "$packages_dir"/aur.local ]]; then
        aur_overrides="$(<"$packages_dir"/aur.local)"
        printf -v aur "${aur}\n${aur_overrides}"
    fi
    if [[ -f "$packages_dir"/apt.local ]]; then
        apt_overrides="$(<"$packages_dir"/apt.local)"
        printf -v apt "${apt}\n${apt_overrides}"
    fi
}

function link_dotfiles {
    # change to the dotfiles directory
    cd $config_dir
    echo ""

    # Check if existing file in homedir and warn if so, otherwise create symlinks from the
    # files in the dotfiles directory specified in $files to the homedir
    for file in $home_files; do
        if [[ -f $file || -d $file ]]; then
            if [[ -f ~/.$file || -d ~/.$file ]]; then
                echo "Skipping: $file because ~/.$file already exists"
            else
                echo "Linking: $file ($config_dir/$file -> ~/.$file)"
                ln -s $config_dir/$file ~/.$file
            fi
        fi
    done
    for file in $configs; do
        if [[ -f $file || -d $file ]]; then
            if [[ -f ~/.config/$file || -d ~/.config/$file ]]; then
                echo "Skipping: $file because ~/.config/$file already exists"
            else
                echo "Linking: $file ($config_dir/$file -> ~/.config/$file)"
                ln -s $config_dir/$file ~/.config/$file
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
            echo "Updating AUR programs."
            yay -Syua $pacman_args
            echo -n "Would you like to install all AUR programs from package lists? (y/n) "
            read response
            if [[ $response == 'y' ]] || [[ $response == 'Y' ]]; then
                echo "Installing AUR programs from package lists."
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
    # Only ask to setup if zsh installed and not the current shell
    if [[ $(program_installed zsh) == 1 && "$SHELL" != "$(which zsh)" ]]; then
        echo
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
    if [ $(program_installed lightdm) == 1 ]; then
        echo
        echo "Enabling numlock at startup"
        original=`cat /etc/lightdm/lightdm.conf` >> /dev/null
        sudo sed --in-place=.backup 's/#greeter-setup-script=/greeter-setup-script=\/usr\/bin\/numlockx on/g' /etc/lightdm/lightdm.conf
        edited=`cat /etc/lightdm/lightdm.conf` >> /dev/null
        diff=`diff <(echo "$original") <(echo "$edited")`
        if [[ "$diff" != '' ]]; then
            echo "$diff"
            restart_needed=1
        else
            echo
            echo "No changes were made"
        fi
    fi

    # Assume Steam is desired if xdg-desktop-portal is installed
    if [[ -f /usr/share/xdg-desktop-portal/portals/gtk.portal && $(program_installed i3) == 1 ]]; then
        echo
        echo "Enabling xdg-desktop-portal-gtk in i3 (needed for Steam)"
        original=`cat /usr/share/xdg-desktop-portal/portals/gtk.portal` >> /dev/null
        sudo sed --in-place=.backup 's/^UseIn=gnome$/UseIn=gnome;i3/g' /usr/share/xdg-desktop-portal/portals/gtk.portal
        edited=`cat /usr/share/xdg-desktop-portal/portals/gtk.portal` >> /dev/null
        diff=`diff <(echo "$original") <(echo "$edited")`
        if [[ "$diff" != '' ]]; then
            echo "$diff"
            restart_needed=1
        else
            echo
            echo "No changes were made"
        fi
        echo
    fi
}

function setup_samba() {
    echo
    echo -n "Would you like to configure samba? (y/n) "
    read response
    if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
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
    fi
    echo
    unset samba_host
}

function fix_package_query() {
    # TODO: This is outdated, endeavouros uses yay instead of pacaur
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
        cd "$dir"
    fi
}

function push_dotfiles() {
    cd "$dir"
    echo "Pushing dotfiles"
    git add -A
    git commit
    git push origin master
}

function update_dotfiles() {
    cd "$dir"
    git pull origin master
}

function install_local() {
    if [ -f "$dir/install_local.sh" ]; then
        "$dir"/install_local.sh
    else
        echo "No file at install_local.sh, skipping local installation script."
    fi
}

function main() {
    if [[ $(program_installed pacman) == 1 ]]; then
        echo "[complete] Complete install (dotfiles, pacman, aur, system-configs, samba, local-install)"
    elif [[ $(program_installed apt) == 1 ]]; then
        echo "[complete] Complete install (dotfiles, apt, system-configs, samba, local-install)"
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
    echo "[install-local] Run local installer only ($dir/install_local.sh)"
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
    elif [[ $response == "install-local" ]]; then
        install_local
        echo ""
        main
    fi
}

load_package_lists
main
