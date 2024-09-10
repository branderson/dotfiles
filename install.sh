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
# TODO: Setup fingerprint reader
# Copy /etc/pam.d/ configs
# auth sufficient pam_fprintd.so
# /etc/pam.d/[kde, kde-fingerprint, login, sddm, sudo, i3lock, etc?]
#
# TODO: Setup touchpad gestures
# yay -S libinput-gestures
# sudo gpasswd -a "$USER" input
# libinput-gestures-setup autostart
# Need to logout here or otherwise reload groups
# libinput-gestures-setup start
# Config in .config/libinput-gestures.conf

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
profile
bash_aliases
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
picom-extended.conf
libinput-gestures.conf
"
local_home_templates="
zshrc_local
profile.local
"
bin="
startplasma-sway-wayland
"
systemd_services="
"
xsessions="
plasma-i3.desktop
"
wayland_sessions="
plasma-sway.desktop
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
    for file in $local_home_templates; do
        if [[ -f $file || -d $file ]]; then
            if [[ -f ~/.$file || -d ~/.$file ]]; then
                echo "Skipping: $file because ~/.$file already exists"
            else
                echo "Copying: $file ($config_dir/$file -> ~/.$file)"
                ln -s $config_dir/$file ~/.$file
            fi
        fi
    done
    for file in $bin; do
        if [[ -f bin/$file && -x $file ]]; then
            if [[ -f /usr/local/bin/$file ]]; then
                echo "Skipping: $file because /usr/local/bin/$file already exists"
            else
                echo "Copying: $file ($config_dir/bin/$file -> /usr/local/bin/$file)"
                sudo cp $config_dir/bin/$file /usr/local/bin/$file
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
                # TODO: Probably should also enable the service
                #systemctl --user enable --now $file
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
        sudo systemctl enable --now sshd.service
    fi
    if [[ $(program_installed ssh-agent) == 1 && $(service_enabled ssh-agent.service) == 0 ]]; then
        echo
        echo "Enabling SSH agent"
        systemctl --user enable --now ssh-agent.service
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
        sudo systemctl enable --now bluetooth.service
    fi

    if [[ $(program_installed syncthing) == 1 ]]; then
        echo
        echo "Enabling Syncthing"
        systemctl enable --user --now syncthing.service
        echo "Configure syncthing here:"
        echo "http://localhost:8384"
    fi
    choose_desktop_environment
}

function setup_sessions() {
    # Install plasma + i3 sessions
    echo
    echo -n "Would you like to install X11 / Wayland sessions? (y/n) "
    read response
    if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
        # Check if xsessions directory exists
        if [[ -d /usr/share/xsessions ]]; then
            for file in $xsessions; do
                if [[ -f xsessions/$file ]]; then
                    if [[ -f /usr/share/xsessions/$file ]]; then
                        echo "Skipping: $file because /usr/share/xsessions/$file already exists"
                    else
                        echo "Copying: $file ($config_dir/xsessions/$file -> /usr/share/xsessions/$file)"
                        sudo cp $config_dir/xsessions/$file /usr/share/xsessions/$file
                    fi
                fi
            done
        fi
        # Check if wayland_sessions directory exists
        if [[ -d /usr/share/wayland-sessions ]]; then
            for file in $wayland_sessions; do
                if [[ -f wayland-sessions/$file ]]; then
                    if [[ -f /usr/share/wayland-sessions/$file ]]; then
                        echo "Skipping: $file because /usr/share/wayland-sessions/$file already exists"
                    else
                        echo "Copying: $file ($config_dir/wayland-sessions/$file -> /usr/share/wayland-sessions/$file)"
                        sudo cp $config_dir/wayland-sessions/$file /usr/share/wayland-sessions/$file
                    fi
                fi
            done
        fi
    fi
}

function choose_desktop_environment() {
    echo
    echo "Choose a desktop environment"
    echo "[plasma-i3] Plasma desktop environment with i3 as window manager"
    echo "[i3] i3 window manager only"
    echo "[plasma] Set up samba credentials only"
    echo "[0] No change"
    echo ""
    echo "What would you like to do?"
    read response
    if [[ $response == "plasma-i3" ]]; then
        setup_plasma_i3
    elif [[ $response == "i3" ]]; then
        setup_bare_i3
    elif [[ $response == "plasma" ]]; then
        setup_bare_plasma
    else
        echo "Making no changes to desktop environment"
    fi
}

function setup_bare_i3() {
    echo "Configuring i3"
    # TODO: Set display manager to lightdm?
    if [[ ! -d ~/.config/i3/config.de ]]; then
        mkdir ~/.config/i3/config.de
    fi
    if [[ -f ~/.config/i3/config.de/i3-keybindings.conf ]]; then
        echo "Skipping: i3-keybindings.conf because ~/.config/i3/config.de/i3-keybindings.conf already exists"
    else
        echo "Linking: i3-keybindings.conf ($config_dir/bare-i3/i3-keybindings.conf -> ~/.config/i3/config.de/i3-keybindings.conf)"
        ln -s $config_dir/bare-i3/i3-keybindings.conf ~/.config/i3/config.de/i3-keybindings.conf
    fi

    if [[ -f ~/.config/i3/config.de/i3-bar.conf ]]; then
        echo "Skipping: i3-bar.conf because ~/.config/i3/config.de/i3-bar.conf already exists"
    else
        echo "Linking: i3-bar.conf ($config_dir/bare-i3/i3-bar.conf -> ~/.config/i3/config.de/i3-bar.conf)"
        ln -s $config_dir/bare-i3/i3-bar.conf ~/.config/i3/config.de/i3-bar.conf
    fi

    if [[ -f ~/.config/i3/config.de/i3-autostart.conf ]]; then
        echo "Skipping: i3-autostart.conf because ~/.config/i3/config.de/i3-autostart.conf already exists"
    else
        echo "Linking: i3-autostart.conf ($config_dir/bare-i3/i3-autostart.conf -> ~/.config/i3/config.de/i3-autostart.conf)"
        ln -s $config_dir/bare-i3/i3-autostart.conf ~/.config/i3/config.de/i3-autostart.conf
    fi
    # TODO: Actually launch into i3 rather than plasma, need to set up DM configs
}

function setup_plasma_i3() {
    if [[ ! $(program_installed plasmashell) == 1 ]]; then
        echo "Plasma not installed, please install and rerun"
        # TODO: echo the command to install plasma
        return 1
    fi

    echo "Configuring i3"
    if [[ -f ~/.config/i3/config.de/i3-keybindings.conf ]]; then
        echo "Skipping: i3-keybindings.conf because ~/.config/i3/config.de/i3-keybindings.conf already exists"
    else
        echo "Linking: i3-keybindings.conf ($config_dir/plasma-i3/i3-keybindings.conf -> ~/.config/i3/config.de/i3-keybindings.conf)"
        ln -s $config_dir/plasma-i3/i3-keybindings.conf ~/.config/i3/config.de/i3-keybindings.conf
    fi

    if [[ -f ~/.config/i3/config.de/i3-bar.conf ]]; then
        echo "Skipping: i3-bar.conf because ~/.config/i3/config.de/i3-bar.conf already exists"
    else
        echo "Linking: i3-bar.conf ($config_dir/plasma-i3/i3-bar.conf -> ~/.config/i3/config.de/i3-bar.conf)"
        ln -s $config_dir/plasma-i3/i3-bar.conf ~/.config/i3/config.de/i3-bar.conf
    fi

    echo "Disabling plasma systemd autostart"
    if [[ $(program_installed kwriteconfig5) == 1 ]]; then
        kwriteconfig5 --file startkderc --group General --key systemdBoot false
    fi
    if [[ $(program_installed kwriteconfig6) == 1 ]]; then
        kwriteconfig6 --file startkderc --group General --key systemdBoot false
    fi

    setup_sessions
}

function setup_bare_plasma() {
    if [[ ! $(program_installed plasmashell) == 1 ]]; then
        echo "Plasma not installed, please install and rerun"
        return 1
    fi

    echo "Configuring plasma"
    # TODO: Copy over plasma configs (or just do this by default with other configs)
    # Mostly we just want to not do the things we do in the other DE functions here
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

function setup_ssh() {
    echo
    echo -n "Would you like to configure an SSH host? (y/n) "
    read response
    if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
        if [[ ! -f ~/.ssh/id_ed25519.pub ]]; then
            echo "No SSH key found"
            echo -n "Would you like to set up a new public/private key pair? (y/n) "
            read response
            if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
                ssh-keygen -t ed25519
                echo

                echo -n "Would you like to add this key to ssh-agent? (y/n) "
                read response
                if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
                    ssh-add ~/.ssh/id_ed25519
                fi
            fi
            echo
        fi
        echo -n "What host would you like to send public key to? (eg user@host, host if user is same) "
        read ssh_host
        if [[ "$ssh_host" != '' ]]; then
            ssh-copy-id -i ~/.ssh/id_ed25519.pub "$ssh_host"
            unset ssh_host
            setup_ssh
        fi
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
    fi
    echo "[system-configs] Set up system configs only"
    echo "[desktop-environment] Choose a desktop environment"
    echo "[samba] Set up samba credentials only"
    echo "[ssh] Set up SSH or send public key to host"
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
    elif [[ $response == "desktop-environment" ]]; then
        choose_desktop_environment
        echo ""
        main
    elif [[ $response == "samba" ]]; then
        setup_samba
        echo ""
        main
    elif [[ $response = "ssh" ]]; then
        setup_ssh
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
