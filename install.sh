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

# TODO: Setup github credentials
# gh auth login
# Possibly set up a credential store

# TODO: Separate out themes and make gruvbox optional

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
# Files and directories under ~/.config
configs="
nvim
i3
alacritty
dunst
conky
rofi
gtk-3.0
powerline
xfce4
picom.conf
"
systemd_services="
plasma-i3.service
"
arch="
"
apt=""
aur="
"
flatpak="
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
    if [[ -f "$packages_dir"/flatpak.local ]]; then
        flatpak_overrides="$(<"$packages_dir"/flatpak.local)"
        printf -v flatpak "${flatpak}\n${flatpak_overrides}"
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
    for file in $systemd_services; do
        if [[ -f systemd/user/$file || -d systemd/user/$file ]]; then
            if [[ -f ~/.config/systemd/user/$file || -d ~/.config/systemd/user/$file ]]; then
                echo "Skipping: $file because ~/.config/systemd/user/$file already exists"
            else
                echo "Linking: $file ($config_dir/systemd/user/$file -> ~/.config/systemd/user/$file)"
                ln -s $config_dir/systemd/user/$file ~/.config/systemd/user/$file
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
                while IFS= read -r program || [[ -n $program ]]; do
                    # Check for comment or whitespace
                    if [[ "$program" == '#'* || -z "${program// }" ]]; then
                        continue
                    fi
                    if [ $(program_installed $program) == 0 ]; then
                        yay -Sqa $pacman_args $program
                    fi
                done < <(printf '%s' "$aur")
            fi
        fi
    fi
}

function install_programs() {
    if [ $(program_installed pacman) == 1 ]; then
        sudo pacman -Syuq
        # https://superuser.com/a/284226
        while IFS= read -r program || [[ -n $program ]]; do
            # Check for comment or whitespace
            if [[ "$program" == '#'* || -z "${program// }" ]]; then
                continue
            fi
            if [ $(program_installed $program) == 0 ]; then
                sudo pacman -Sq $pacman_args $program
            fi
        done < <(printf '%s' "$arch")
    elif [ $(program_installed apt-get) == 1 ]; then
        sudo apt-get update
        while IFS= read -r program || [[ -n $program ]]; do
            # Check for comment or whitespace
            if [[ "$program" == '#'* || -z "${program// }" ]]; then
                continue
            fi
            if [ $(program_installed $program) == 0 ]; then
                sudo apt-get install $program
            fi
        done < <(printf '%s' "$apt")
    else
        echo "Cannot install programs, no compatible package manager."
    fi
    if [ $(program_installed flatpak) == 1 ]; then
        flatpak update --noninteractive --assumeyes
        while IFS= read -r program || [[ -n $program ]]; do
            # Check for comment or whitespace
            if [[ "$program" == '#'* || -z "${program// }" ]]; then
                continue
            fi
            program_array=($program)
            remote=${program_array[0]}
            app=${program_array[1]}
            flatpak install --noninteractive --assumeyes $remote $app
        done < <(printf '%s' "$flatpak")
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
    if [[ $(program_installed sshd) == 1 && $(service_enabled sshd.service) == 0 ]]; then
        echo
        echo "Enabling SSH server"
        sudo systemctl enable sshd.service
        sudo systemctl start sshd.service
    fi
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
            echo "No changes were made"
        fi
    fi

    if [[ ! $(program_installed vim) == 1 && $(program_installed nvim) == 1 ]]; then
        echo
        echo "Preventing missing vim issues"
        sudo ln -s "$(which nvim)" /usr/bin/vim
    fi

    # TODO: Make sure bluetooth is installed
    if [[ $(service_enabled bluetooth.service) == 0 ]]; then
        echo
        echo "Enabling Bluetooth"
        sudo systemctl enable bluetooth.service
        sudo systemctl start bluetooth.service
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
        install_local
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
