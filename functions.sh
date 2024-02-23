# TODO: Flip the return values of these, 0 should be true by POSIX convention

# Returns 1 if program is installed and 0 otherwise
function program_installed {
    local return_=1

    type $1 >/dev/null 2>&1 || { local return_=0; }

    echo "$return_"
}

# Returns 1 if service is enabled and 0 otherwise
function service_enabled {
    local return_=1

    systemctl is-enabled --quiet $1 || { local return_=0; }

    echo "$return_"
}

# Returns 1 if user service is enabled and 0 otherwise
function user_service_enabled {
    local return_=1

    systemctl --user is-enabled --quiet $1 || { local return_=0; }

    echo "$return_"
}
