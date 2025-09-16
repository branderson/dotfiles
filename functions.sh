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
