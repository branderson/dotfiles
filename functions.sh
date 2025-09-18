# Returns 0 if program is installed and 1 otherwise
function program_installed {
    local return_=0

    type $1 >/dev/null 2>&1 || { local return_=1; }

    return "$return_"
}

# Returns 0 if service is enabled and 1 otherwise
function service_enabled {
    local return_=0

    systemctl is-enabled --quiet $1 || { local return_=1; }

    return "$return_"
}

# Returns 1 if user service is enabled and 0 otherwise
function user_service_enabled {
    local return_=0

    systemctl --user is-enabled --quiet $1 || { local return_=1; }

    return "$return_"
}

function update_dotfiles_config {
    if [ "$#" != 2 ]; then
        echo "Usage: update_dotfiles_config ENV_VARIABLE VALUE"
        exit 1
    fi
    local var="$1"
    local val="$2"

    if [ ! -f "$HOME/.dotfiles-config" ]; then
        touch "$HOME/.dotfiles-config"
    fi
    if [ $(cat "$HOME/.dotfiles-config" | grep -Eq "^export $1=.*$") ]; then
        sed -i "s/$1=.*$/$1=$2/" "$HOME/.dotfiles-config"
    else
        echo "export $1=$2" >> "$HOME/.dotfiles-config"
    fi
}
