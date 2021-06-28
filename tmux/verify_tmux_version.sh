#!/bin/bash

verify_tmux_version() {
    tmux_home=~/.tmux
    tmux_version="$(tmux -V | cut -c 6-)"

    # This is necessary because 3.1c gives a syntax error in bc
    # TODO Fix this it will break with the next tmux version
    if [[ $tmux_version -eq "3.1c"]] ; then
        tmux source-file $tmux_home/tmux_3.1c.conf
        exit
    if [[ $(echo "$tmux_version >= 2.5" | bc) -eq 1 ]] ; then
        tmux source-file $tmux_home/tmux_3.1c.conf
        exit
    elif [[ $(echo "$tmux_version >= 2.1" | bc) -eq 1 ]] ; then
        tmux source-file $tmux_home/tmux_2.1_to_2.5.conf
        exit
    elif [[ $(echo "$tmux_version >= 1.9" | bc) -eq 1 ]] ; then
        tmux source-file $tmux_home/tmux_1.9_to_2.1.conf
        exit
    else
        tmux source-file $tmux_home/tmux_1.9_down.conf
        exit
    fi
}

verify_tmux_version
