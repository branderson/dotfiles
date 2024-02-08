# Returns 1 if program is installed and 0 otherwise
function program_installed {
    local return_=1

    type $1 >/dev/null 2>&1 || { local return_=0; }

    echo "$return_"
}
