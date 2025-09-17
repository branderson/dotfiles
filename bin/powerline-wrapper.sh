#!/bin/bash
# Wrapper script around powerline to force a PYTHONPATH without setting it globally

source "$HOME/.bash_functions"
POWERLINE_BASH_SOURCES=( $(powerline_bash_sources) )
found=0
# Find site_packages with powerline installed
for file in "${POWERLINE_BASH_SOURCES[@]}"; do
    if [ -a "$file" ]; then
        # Get the corresponding site-packages root
        site_packages="$file"
        for i in {1..4}; do
            site_packages=$(dirname "$site_packages")
        done
        found=1
        break
    fi
done

if [ $found == 1 ]; then
    PYTHONPATH="$site_packages" powerline "$@"
else
    echo "Powerline site_packages not found"
    exit 1
fi
