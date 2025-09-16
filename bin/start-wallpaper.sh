#!/bin/bash
# TODO: Dotfiles may be in a different place
if [ ! -f "$HOME/.dotfiles-dir" ]; then
    echo "$HOME/.dotfiles-dir not found, please run dotfiles/install.sh to create it"
    exit 1
fi
source "$HOME/.dotfiles-dir"
source "$DOTFILES_DIR/functions.sh"

# XAUTHORITY file may be in /tmp or it may be ~/.XAUTHORITY
if [ -f "$HOME/.Xauthority" ]; then
    export XAUTHORITY="$HOME/.Xauthority"
else
    auth_path="$(find /tmp -maxdepth 1 -name "xauth_*")"
    if [ ! -z "$auth_path" ]; then
        export XAUTHORITY="$auth_path"
    else
        echo "No Xauthority file found. Exiting"
        exit 1
    fi
fi
wallpapers_path="$HOME/wallpapers"
wallpapers_vertical_path="$HOME/wallpapers-vertical"

if [ ! -d "$wallpapers_path" ]; then
    echo "ERROR: Wallpaper directory not found!"
    echo "Please create wallpapers directory in $wallpapers_path"
    exit 1
fi

if program_installed xrandr; then
    display_count="$(xrandr | grep ' connected ' | wc -l)"
    # Get the selected resolution for each display
    display_resolutions="$(xrandr | grep '*' | awk '{ print $1}')"
    # Get the rotation for each display, need verbose to return rotation if normal
    # and remove 'primary' for consistent column placement
    display_rotations="$(xrandr --query --verbose | grep ' connected ' | sed 's/primary //' | awk '{print $5}')"
    # Build feh command
    feh_args=("--bg-fill")
    for i in $(seq 1 "$display_count"); do
        resolution="$(echo "$display_resolutions" | sed "${i}q;d")"
        rotation="$(echo "$display_rotations" | sed "${i}q;d")"
        path="$wallpapers_path"
        resolution_segment=""
        if [ "$rotation" != "normal" ] && [ "$rotation" != "inverted" ]; then
            if [ ! -d "$wallpapers_vertical_path" ]; then
                echo "$rotation"
                echo "ERROR: Vertical display detected, but vertical wallpapers directory not found!"
                echo "Please create vertical wallpapers directory in $wallpapers_vertical_path"
                exit 1
            fi
            path="$wallpapers_vertical_path"
        fi
        # If we have a resolution-specific path for the display, use it
        if [ -d "$path/1080p" ]; then
            resolution_segment="/1080p"
        fi
        if [ -d "$path/4k" ]; then
            if [ "$resolution" = "3840x2160" ] || [ "$resolution" = "2160x3840" ]; then
                resolution_segment="/4k"
            fi
        fi
        display_wallpaper="$(shuf -en1 "$path$resolution_segment"/*)"
        feh_args+=("$display_wallpaper")
    done
    echo "feh ${feh_args[@]}"
    feh "${feh_args[@]}"
else
    # Default to ~/wallpapers/1080p or ~/wallpapers for first display if no xrandr
    if [ -d "$path/1080p" ]; then
        feh --bg-fill "$(shuf -en1 $wallpapers_path/1080p/*)"
    else
        feh --bg-fill "$(shuf -en1 $wallpapers_path/*)"
    fi
fi
