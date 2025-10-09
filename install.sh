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

# TODO: sed -i -e s/AddKeysToAgent.*$/AddKeysToAgent yes/g' .ssh/config
# Create the file if doesn't exist
# Add the line if it's not present
#
# TODO: Setup fingerprint reader
# fprintd-enroll brad -f right-index-finger
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

# TODO: Restart needed needs to be implemented

# TODO: non-interactive should be used throughout the codebase

# TODO: Support different install types (user, server, hardened, IoT, devbox)

# TODO: If on mac, install brew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# TODO: If on mac, install powerline-status
# pipx install --index-url https://pypi.org/simple powerline-status

# TODO: If on mac, install powerline-fonts
# git clone https://github.com/powerline/fonts.git --depth=1 && cd fonts && ./install.sh && cd - && rm -rf ./fonts
# Or just add powerline-fonts as a dependency submodule
# Then go into iTerm2 settings and set Source Code Pro for Powerline as the font

dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" # dotfiles repository directory
if [ -f "$HOME/.dotfiles-dir" ]; then
    # Migrate legacy config
    echo "Migrating .dotfiles-dir to .dotfiles-config"
    mv "$HOME/.dotfiles-dir" "$HOME/.dotfiles-config"
fi
if [ ! -f "$HOME/.dotfiles-config" ]; then
    if [ ! -f "$dir/install.sh" ] || [ ! -f "$dir/dotfiles-local.sh" ]; then
        echo "Please run this script initially from within the dotfiles directory"
        exit 1
    fi
    echo "Writing 'export DOTFILES_DIR=$dir' to $HOME/.dotfiles-config"
    echo "export DOTFILES_DIR=$dir" > "$HOME/.dotfiles-config"
else
    echo "Loading existing $HOME/.dotfiles-config"
fi
source "$HOME/.dotfiles-config"
unset dir
source "$DOTFILES_DIR"/functions.sh
config_dir="$DOTFILES_DIR"/config
packages_dir="$DOTFILES_DIR"/packages
platform=$(uname)
pacman_args="--noconfirm --needed"

restart_needed=0
interactive=0

if [ ! -L $DOTFILES_DIR/bin/dotfiles-install ]; then
    echo "Adding this script to PATH. 'dotfiles-install' to run in the future"
    ln -s "$DOTFILES_DIR/install.sh" "$DOTFILES_DIR/bin/dotfiles-install"
fi

# Files and directories to link to home directory
home_files="
zshrc
zsh_functions
profile
bash_aliases
bash_profile
bashrc
bash_functions
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
systemd_services="
"
xsessions="
plasma-i3.desktop
"
wayland_sessions="
plasma-sway.desktop
"
arch=""
apt=""
brew=""
aur=""
flatpak=""
gem=""
pipx=""

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
    if [[ -f "$packages_dir"/flatpak.global ]]; then
        flatpak="$(<"$packages_dir"/flatpak.global)"
    fi
    if [[ -f "$packages_dir"/gem.global ]]; then
        gem="$(<"$packages_dir"/gem.global)"
    fi
    if [[ -f "$packages_dir"/pipx.global ]]; then
        pipx="$(<"$packages_dir"/pipx.global)"
    fi
    if [[ -f "$packages_dir"/brew.global ]]; then
        brew="$(<"$packages_dir"/brew.global)"
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
    if [[ -f "$packages_dir"/gem.local ]]; then
        gem_overrides="$(<"$packages_dir"/gem.local)"
        printf -v gem "${gem}\n${gem_overrides}"
    fi
    if [[ -f "$packages_dir"/pipx.local ]]; then
        pipx_overrides="$(<"$packages_dir"/pipx.local)"
        printf -v pipx "${pipx}\n${pipx_overrides}"
    fi
    if [[ -f "$packages_dir"/brew.local ]]; then
        brew_overrides="$(<"$packages_dir"/brew.local)"
        printf -v brew "${brew}\n${brew_overrides}"
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
            if [[ -L $HOME/.$file ]]; then
                echo "Skipping: $file because ~/.$file already linked"
            # Don't skip if not interactive as initial files often exist that should be replaced
            elif [[ (-f $HOME/.$file || -d $HOME/.$file) && $interactive -eq 1 ]]; then
                echo "Skipping: $file because ~/.$file already exists"
            else
                echo "Linking: $file ($config_dir/$file -> ~/.$file)"
                ln -s $config_dir/$file $HOME/.$file
            fi
        fi
    done
    for file in $configs; do
        if [[ -f $file || -d $file ]]; then
            if [[ -L "$HOME/.config/$file" ]]; then
                echo "Skipping: $file because ~/.config/$file already linked"
            elif [[ -f $HOME/.config/$file || -d $HOME/.config/$file ]]; then
                echo "Skipping: $file because ~/.config/$file already exists"
            else
                echo "Linking: $file ($config_dir/$file -> ~/.config/$file)"
                ln -s $config_dir/$file $HOME/.config/$file
            fi
        fi
    done
    for file in $local_home_templates; do
        if [[ -f ./local-templates/$file || -d ./local-templates/$file ]]; then
            if [[ -L "$HOME/.$file" ]]; then
                echo "Skipping: $file because ~/.$file already linked"
            elif [[ -f $HOME/.$file || -d $HOME/.$file ]]; then
                echo "Skipping: $file because ~/.$file already exists"
            else
                echo "Copying: $file ($config_dir/local-templates/$file -> ~/.$file)"
                ln -s $config_dir/local-templates/$file $HOME/.$file
            fi
        fi
    done
    for file in $systemd_services; do
        if [[ -f systemd/user/$file || -d systemd/user/$file ]]; then
            if [[ -L "$HOME/.config/systemd/user/$file" ]]; then
                echo "Skipping: $file because ~/.config/systemd/user/$file already linked"
            elif [[ -f $HOME/.config/systemd/user/$file || -d $HOME/.config/systemd/user/$file ]]; then
                echo "Skipping: $file because ~/.config/systemd/user/$file already exists"
            else
                echo "Linking: $file ($config_dir/systemd/user/$file -> ~/.config/systemd/user/$file)"
                ln -s $config_dir/systemd/user/$file $HOME/.config/systemd/user/$file
                # TODO: Probably should also enable the service
                #systemctl --user enable --now $file
            fi
        fi
    done
    cd - > /dev/null
}

function link_dotfiles_local() {
    if [ -d "$DOTFILES_DIR/dependencies/dotfiles-local" ]; then
        cd "$DOTFILES_DIR/dependencies/dotfiles-local"
        # Check if on main branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [ "$current_branch" == "main" ]; then
            if [ "$interactive" == 0 ]; then
                echo "Local dotfiles repo on branch $current_branch and tool running non-interactively."
                echo "Setting branch to $(hostname)"
                current_branch=$(hostname)
                # echo "Please set branch by running:"
                # echo "> $DOTFILES_DIR/dotfiles-local.sh {machine-name}"
                # return
            fi
        fi
        cd -
    else
        echo "Local dotfiles repo not found. Cloning into dependencies"
        if [ "$interactive" == 0 ]; then
            echo "Tool running non-interactively. Setting branch to $(hostname)"
        else
            echo -n "What machine name would you like to use for this branch? [$(hostname)] "
            read response
            if [ -z "$response" ]; then
                current_branch=$(hostname)
            else
                current_branch="$response"
            fi
        fi
    fi
    echo ""
    "$DOTFILES_DIR"/dotfiles-local.sh "$current_branch"
}

function install_aur() {
    # install AUR programs if on Arch
    if program_installed yay; then
        echo ""
        echo "Installing and updating AUR packages"
        yay -Syua $pacman_args
        to_install=()
        while IFS= read -r program || [[ -n $program ]]; do
            # Check for comment or whitespace
            if [[ "$program" == '#'* || -z "${program// }" ]]; then
                continue
            fi
            if ! program_installed $program; then
                to_install+=("$program")
            fi
        done < <(printf '%s' "$aur")
        if [ "${#to_install[@]}" -gt 0 ]; then
            yay -Sqa $pacman_args "${to_install[@]}"
        fi
    fi
}

function install_main() {
    if program_installed pacman; then
        echo ""
        echo "Installing and updating pacman packages"
        sudo pacman -Syu
        while IFS= read -r program || [[ -n $program ]]; do
            # Check for comment or whitespace
            if [[ "$program" == '#'* || -z "${program// }" ]]; then
                continue
            fi
            if ! program_installed $program; then
                to_install+=("$program")
            fi
        done < <(printf '%s' "$arch")
        if [ "${#to_install[@]}" -gt 0 ]; then
            sudo pacman -Sq $pacman_args "${to_install[@]}"
        fi
    elif program_installed apt-get; then
        echo ""
        echo "Installing and updating apt packages"
        sudo apt-get update
        sudo apt-get upgrade
        to_install=()
        while IFS= read -r program || [[ -n $program ]]; do
            # Check for comment or whitespace
            if [[ "$program" == '#'* || -z "${program// }" ]]; then
                continue
            fi
            if ! program_installed $program; then
                to_install+=("$program")
            fi
        done < <(printf '%s' "$apt")
        if [ "${#to_install[@]}" -gt 0 ]; then
            sudo apt-get install -y "${to_install[@]}"
        fi
    elif program_installed brew; then
        echo ""
        echo "Installing and updating brew packages"
        brew update
        brew upgrade
        to_install=()
        while IFS= read -r program || [[ -n $program ]]; do
            # Check for comment or whitespace
            if [[ "$program" == '#'* || -z "${program// }" ]]; then
                continue
            fi
            if ! program_installed $program; then
                to_install+=("$program")
            fi
        done < <(printf '%s' "$brew")
        if [ "${#to_install[@]}" -gt 0 ]; then
            brew install "${to_install[@]}"
        fi
    else
        echo "Cannot install programs, no compatible package manager."
    fi
}

function install_flatpak() {
    if program_installed flatpak; then
        echo ""
        echo "Installing and updating flatpak packages"
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

function install_gem() {
    if program_installed gem; then
        echo ""
        echo "Installing and updating gem packages"
        gem update
        to_install=()
        while IFS= read -r program || [[ -n $program ]]; do
            # Check for comment or whitespace
            if [[ "$program" == '#'* || -z "${program// }" ]]; then
                continue
            fi
            to_install+=("$program")
        done < <(printf '%s' "$gem")
        if [ "${#to_install[@]}" -gt 0 ]; then
            gem install "${to_install[@]}"
        fi
    fi
}

function install_pipx() {
    if program_installed pipx; then
        echo ""
        echo "Installing and updating pipx packages"
        pipx upgrade-all
        to_install=()
        while IFS= read -r program || [[ -n $program ]]; do
            # Check for comment or whitespace
            if [[ "$program" == '#'* || -z "${program// }" ]]; then
                continue
            fi
            if ! program_installed $program; then
                to_install+=("$program")
            fi
        done < <(printf '%s' "$pipx")
        if [ "${#to_install[@]}" -gt 0 ]; then
            pipx install "${to_install[@]}"
        fi
    fi
}

function install_gpu_monitoring() {
    if program_installed nvidia-smi; then
        if ! id "nvidia_gpu_exporter" >/dev/null 2>&1; then
            echo 'Creating nvidia_gpu_exporter user'
            sudo useradd --system --no-create-home --shell /usr/sbin/nologin nvidia_gpu_exporter
        fi
        if program_installed dpkg; then
            echo "Installing nvidia-gpu-exporter using dpkg"
            sudo dpkg -i nvidia-gpu-exporter_1.3.1_linux_amd64.deb
        else
            VERSION=1.3.1
            echo "Installing nvidia-gpu-exporter from release binary [version $VERSION]"
            wget -o /dev/null https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v${VERSION}/nvidia_gpu_exporter_${VERSION}_linux_x86_64.tar.gz
            mkdir -p ./nvidia_gpu_exporter
            tar -xvzf nvidia_gpu_exporter_${VERSION}_linux_x86_64.tar.gz -C ./nvidia_gpu_exporter >/dev/null
            rm nvidia_gpu_exporter_${VERSION}_linux_x86_64.tar.gz
            sudo mv nvidia_gpu_exporter/nvidia_gpu_exporter /usr/bin
            rm -r ./nvidia_gpu_exporter
            unset VERSION
        fi
        if program_installed systemctl; then
            echo "Installing systemd service for nvidia-gpu-exporter and enabling"
            sudo wget -o /dev/null -O /etc/systemd/system/nvidia_gpu_exporter.service https://raw.githubusercontent.com/utkuozdemir/nvidia_gpu_exporter/refs/heads/master/systemd/nvidia_gpu_exporter.service >/dev/null
            sudo systemctl daemon-reload
            sudo systemctl enable --now nvidia_gpu_exporter
        fi
        if program_installed firewall-cmd; then
            # Open firewall port in firewalld
            PORT=9835
            # Check if the rule already exists
            if sudo firewall-cmd --state | grep -q '^running'; then
                # firewalld is running
                if ! sudo firewall-cmd --permanent --add-port=$PORT/tcp 2>&1 | grep -q 'ALREADY_ENABLED'; then
                    echo "Opened firewalld port $PORT/tcp for nvidia-gpu-exporter."
                    # Reload firewall to apply changes
                    echo "Reloading firewalld"
                    sudo firewall-cmd --quiet --reload
                else
                    echo "Port $PORT/tcp is already open."
                fi
            fi
            unset PORT
        fi
    fi
}

function setup_zsh() {
    # Only ask to setup if zsh installed and not the current shell
    if program_installed zsh && [ "$SHELL" != "$(which zsh)" ]; then
        echo
        echo -n "Would you like to set zsh as your default shell? (y/N) "
        read response
        if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
            echo "Setting zsh as default shell"
            chsh -s /usr/bin/zsh
        fi
    fi
}

function setup_system_configs() {
    setup_zsh
    if program_installed sshd && ! service_enabled sshd.service; then
        echo
        echo "Enabling SSH server"
        sudo systemctl enable --now sshd.service
    fi
    if program_installed lightdm; then
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
    if [ -f /usr/share/xdg-desktop-portal/portals/gtk.portal ] && program_installed i3; then
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

    # If gnome-keyring is installed and i3, enable its XDG portal backend
    if [ -f /usr/share/xdg-desktop-portal/portals/gnome-keyring.portal ] && program_installed i3; then
        echo
        echo "Enabling xdg-desktop-portal-gnome-keyring in i3"
        original=`cat /usr/share/xdg-desktop-portal/portals/gnome-keyring.portal` >> /dev/null
        sudo sed --in-place=.backup 's/^UseIn=gnome$/UseIn=gnome;i3/g' /usr/share/xdg-desktop-portal/portals/gnome-keyring.portal
        edited=`cat /usr/share/xdg-desktop-portal/portals/gnome-keyring.portal` >> /dev/null
        diff=`diff <(echo "$original") <(echo "$edited")`
        if [[ "$diff" != '' ]]; then
            echo "$diff"
            restart_needed=1
        else
            echo "No changes were made"
        fi
    fi

    if program_installed vim && program_installed nvim && [ ! -f /usr/bin/vim ]; then
        echo
        echo "Preventing missing vim issues"
        sudo ln -s "$(which nvim)" /usr/bin/vim
    fi

    # TODO: Make sure bluetooth is installed
    if ! service_enabled bluetooth.service; then
        echo
        echo "Enabling Bluetooth"
        sudo systemctl enable --now bluetooth.service
    fi

    if program_installed syncthing && ! service_enabled syncthing.service; then
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
    echo -n "Would you like to install X11 / Wayland sessions? (y/N) "
    read response
    if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
        # Check if xsessions directory exists
        if [[ -d /usr/share/xsessions ]]; then
            for file in $xsessions; do
                if [[ -f $config_dir/xsessions/$file ]]; then
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
                if [[ -f $config_dir/wayland-sessions/$file ]]; then
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
    if ! program_installed i3; then
        echo "i3 not installed, please install and rerun"
        return 1
    fi
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

    if [[ -f /etc/systemd/system/update-wallpapers.service ]]; then
        echo "Skipping: update-wallpapers.service because /etc/systemd/system/update-wallpapers.service already exists"
    else
        echo "Linking: update-wallpapers.service ($config_dir/systemd/update-wallpapers.service -> /etc/systemd/system/update-wallpapers.service)"
        sudo ln -s $config_dir/systemd/update-wallpapers.service /etc/systemd/system/update-wallpapers.service
    fi

    if [[ -f /etc/udev/rules.d/85-drm-hotplug.rules ]]; then
        echo "Skipping: 85-drm-hotplug.rules because /etc/udev/rules.d/85-drm-hotplug.rules already exists"
    else
        echo "Linking: 85-drm-hotplug.rules ($config_dir/udev/85-drm-hotplug.rules -> /etc/udev/rules.d/85-drm-hotplug.rules)"
        sudo ln -s $config_dir/udev/85-drm-hotplug.rules /etc/udev/rules.d/85-drm-hotplug.rules
    fi
    # TODO: Actually launch into i3 rather than plasma, need to set up DM configs
}

function setup_plasma_i3() {
    if ! program_installed i3 && ! program_installed plasmashell; then
        echo "Neither i3 nor plasma installed, please install and rerun"
        return 1
    fi
    if ! program_installed i3; then
        echo "i3 not installed, please install and rerun"
        return 1
    fi
    if ! program_installed plasmashell; then
        echo "Plasma not installed, please install and rerun"
        # TODO: echo the command to install plasma
        return 1
    fi

    echo "Copying: startplasma-sway-wayland ($config_dir/bin/startplasma-sway-wayland -> /usr/local/bin/)"
    sudo cp $config_dir/scripts/startplasma-sway-wayland /usr/local/bin/

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

    if [[ -f /etc/systemd/system/update-wallpapers.service ]]; then
        echo "Skipping: update-wallpapers.service because /etc/systemd/system/update-wallpapers.service already exists"
    else
        echo "Linking: update-wallpapers.service ($config_dir/systemd/update-wallpapers.service -> /etc/systemd/system/update-wallpapers.service)"
        sudo ln -s $config_dir/systemd/update-wallpapers.service /etc/systemd/system/update-wallpapers.service
    fi

    if [[ -f /etc/udev/rules.d/85-drm-hotplug.rules ]]; then
        echo "Skipping: 85-drm-hotplug.rules because /etc/udev/rules.d/85-drm-hotplug.rules already exists"
    else
        echo "Linking: 85-drm-hotplug.rules ($config_dir/udev/85-drm-hotplug.rules -> /etc/udev/rules.d/85-drm-hotplug.rules)"
        sudo ln -s $config_dir/udev/85-drm-hotplug.rules /etc/udev/rules.d/85-drm-hotplug.rules
    fi

    echo "Disabling plasma systemd autostart"
    if program_installed kwriteconfig5; then
        kwriteconfig5 --file startkderc --group General --key systemdBoot false
    fi
    if program_installed kwriteconfig6; then
        kwriteconfig6 --file startkderc --group General --key systemdBoot false
    fi

    setup_sessions
}

function setup_bare_plasma() {
    if ! program_installed plasmashell; then
        echo "Plasma not installed, please install and rerun"
        return 1
    fi

    echo "Configuring plasma"
    # TODO: Copy over plasma configs (or just do this by default with other configs)
    # Mostly we just want to not do the things we do in the other DE functions here
    # TODO: Undo the things the other window manager setups do
}

function setup_samba() {
    echo
    echo -n "Would you like to configure an SMB host? (y/N) "
    read response
    if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
        echo -n "What is the friendly name of the SMB host? "
        read samba_host
        echo -n "What is the IP address of the SMB host? "
        read samba_ip
        if [[ "$samba_host" != '' ]] && [[ "$samba_ip" != '' ]]; then
            echo
            echo -n "Would you like to configure SMB credentials for this host? (y/N) "
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
            while true; do
                echo
                echo -n "Would you like to configure an SMB volume mount for this host? (y/N) "
                read response
                if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
                    echo
                    echo -n "What is the SMB volume mount name? "
                    read samba_share
                    echo -n "What directory would you like to mount the volume to in /mnt? "
                    read mnt_dir
                    fstab_line="//$samba_ip/$samba_share    /mnt/$mnt_dir   cifs    _netdev,nofail,x-systemd.automount,uid=$(id -u),gid=$(id -g),credentials=/etc/samba/credentials/$samba_host     0   0" 
                    echo
                    echo "$fstab_line"
                    echo -n "Would you like to write this line to /etc/fstab? (y/N) "
                    read response
                    if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
                        if [ ! -d /mnt/"$mnt_dir" ]; then
                            echo "Creating mount directory /mnt/$mnt_dir"
                            sudo mkdir "/mnt/$mnt_dir"
                        fi
                        echo "Writing volume mount to /etc/fstab"
                        echo "$fstab_line" | sudo tee -a /etc/fstab
                    fi
                    unset response
                else
                    echo "Add lines to /etc/fstab for each share to mount:"
                    echo "//{SAMBA_HOST_IP}/{SAMBA_SHARE}  /mnt/{MOUNT_DIR}    cifs    _netdev,nofail,x-systemd.automount,uid=`id -u`,gid=`id -g`,credentials=/etc/samba/credentials/$samba_host    0   0"
                    break
                fi
            done
        fi
        # Recurse in case another host needs setup
        setup_samba
    fi
    echo
    unset samba_host
}

function setup_ssh() {
    echo
    echo -n "Would you like to configure an SSH host? (y/N) "
    read response
    if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
        if [ ! -d "$HOME/.ssh" ]; then
            mkdir "$HOME/.ssh"
        fi
        if [[ ! -f $HOME/.ssh/id_ed25519.pub ]]; then
            echo "No SSH key found"
            echo -n "Would you like to set up a new public/private key pair? (y/N) "
            read response
            if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
                ssh-keygen -t ed25519
                echo

                echo -n "Would you like to add this key to ssh-agent? (y/N) "
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

function setup_coder() {
    echo "Installing coder"
    curl -L https://coder.com/install.sh | sh
    coder login https://coderbox.branderson.io
    coder config-ssh
}

function push_dotfiles() {
    cd "$DOTFILES_DIR"
    echo "Pushing dotfiles"
    git add -A
    git commit
    git push origin master
}

function update_dotfiles() {
    cd "$DOTFILES_DIR"
    git pull origin master
}

function install_local() {
    if [ -f "$DOTFILES_DIR/install_local.sh" ]; then
        "$DOTFILES_DIR"/install_local.sh
    else
        echo "No file at install_local.sh, skipping local installation script."
    fi
}

function list_options() {
    if program_installed pacman; then
        if program_installed yay; then
            echo "[complete] Complete install (dotfiles, pacman, aur, flatpak, gem, pipx, system-configs, samba, local-install)"
        else
            echo "[complete] Complete install (dotfiles, pacman, flatpak, gem, pipx, system-configs, samba, local-install)"
        fi
    elif program_installed apt; then
        echo "[complete] Complete install (dotfiles, apt, flatpak, gem, pipx, system-configs, samba, install-local)"
    elif program_installed brew; then
        echo "[complete] Complete install (dotfiles, brew, flatpak, gem, pipx, system-configs, samba,install-local)"
    fi
    echo "[dotfiles] Install dotfiles only"
    echo "[dotfiles-local] Sync local dotfiles to git"
    if program_installed pacman; then
        echo "[programs] Install programs from all package managers (pacman, aur, flatpak, gem)"
    elif program_installed apt; then
        echo "[programs] Install programs from all package managers (apt, flatpak, gem)"
        echo "[programs] Install programs from (apt) only"
    elif program_installed brew; then
        echo "[programs] Install programs from all package managers (brew, flatpak, gem)"
        echo "[programs] Install programs (brew) only"
    fi
    if program_installed pacman; then
        echo "[programs-main] Install main package manager (pacman) only"
        if program_installed yay; then
            echo "[programs-aur] Install AUR programs only"
        fi
    elif program_installed apt; then
        echo "[programs-main] Install main package manager (apt) only"
    elif program_installed brew; then
        echo "[programs-main] Install main package manager (brew) only"
    fi
    if program_installed nvidia-smi; then
        echo "[gpu-monitoring] Install nvidia-gpu-exporter"
    fi
    echo "[system-configs] Set up system configs only"
    echo "[desktop-environment] Choose a desktop environment"
    echo "[samba] Set up samba credentials only"
    echo "[ssh] Set up SSH or send public key to host"
    echo "[coder] Set up coder and login to coderbox"
    echo "[install-local] Run local installer only ($DOTFILES_DIR/install_local.sh)"
    echo "[push] Push to gitbox"
    echo "[pull] Pull from gitbox"
    echo "[quit] Quit"
}

function run_interactively() {
    unset response
    if [ -n "$1" ]; then
        # Use the first CLI argument if provided
        response="$1"
    fi
    if [ ! -n "$response" ]; then
        list_options
        echo ""
        echo "What would you like to do?"
        read response
    fi
    if [[ $response == "complete" ]]; then
        link_dotfiles
        install_main
        install_flatpak
        install_gem
        install_pipx
        echo ""
        if program_installed yay; then
            echo -n "Do you want to upgrade/install from AUR? (y/N) "
            read response
            if [[ $response == 'y' ]] || [[ $response == 'Y' ]]; then
                install_aur
            fi
        fi
        setup_system_configs
        setup_samba
        install_local
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "push" ]]; then
        push_dotfiles
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "pull" ]]; then
        update_dotfiles
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "dotfiles" ]]; then
        link_dotfiles
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "dotfiles-local" ]]; then
        link_dotfiles_local
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "programs" ]]; then
        install_main
        install_flatpak
        install_gem
        install_pipx
        if program_installed yay; then
            echo ""
            echo -n "Do you want to upgrade/install from AUR? (y/N) "
            read response
            if [[ $response == 'y' ]] || [[ $response == 'Y' ]]; then
                install_aur
            fi
        fi
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "programs-main" ]]; then
        install_main
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "aur-only" ]]; then
        install_aur
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "gpu-monitoring" ]]; then
        install_gpu_monitoring
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "system-configs" ]]; then
        setup_system_configs
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "desktop-environment" ]]; then
        choose_desktop_environment
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "samba" ]]; then
        setup_samba
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response = "ssh" ]]; then
        setup_ssh
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response = "coder" ]]; then
        setup_coder
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "install-local" ]]; then
        install_local
        if [ "$#" -eq 0 ]; then
            echo ""
            run_interactively
        fi
    elif [[ $response == "quit" ]]; then
        exit 0
    else
        if [ "$#" -eq 0 ]; then
            echo "Error: Please enter one of the supported options"
            echo ""
            run_interactively
        else
            echo ""
            echo "Usage: dotfiles-install [option]"
            echo "Options:"
            list_options
            exit 1
        fi
    fi
}

load_package_lists

cd "$DOTFILES_DIR"

echo "Updating submodules"
git submodule update --init

# Check if running interactively
if [ -t 0 ]; then
    # Interactive session
    interactive=1
    run_interactively "$@"
else
    # Non-interactive session (e.g. Coder workspace initialization)
    link_dotfiles
    link_dotfiles_local
    cd -
fi

