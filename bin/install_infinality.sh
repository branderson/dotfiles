#/bin/bash

pacman_repos="
[infinality-bundle]
Server = http://bohoomil.com/repo/\$arch

[infinality-bundle-multilib]
Server = http://bohoomil.com/repo/multilib/\$arch

[infinality-bundle-fonts]
Server = http://bohoomil.com/repo/fonts"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi
if [[ ! -f /etc/pacman.conf ]]; then
    echo "No pacman.conf found. Nothing changed"
elif grep -q infinality /etc/pacman.conf; then
    echo "Infinality repository already present in pacman.conf. Nothing changed"
else
    echo "Installing Infinality repository to pacman.conf"
    sudo echo "$pacman_repos" >> /etc/pacman.conf
    sudo pacman-key -r 962DDE58
    pacman-key --lsign-key 962DDE58

    pacman -Syu
    pacman -S infinality-bundle
    pacman -S infinality-bundle-multilib
    pacman -S infinality-bundle-fonts
fi
