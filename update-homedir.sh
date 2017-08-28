#!/bin/bash

DIR=~/dotfiles                    # dotfiles directory
HOMEDIR=~/homedirs/users/bradleya
SCRIPT_NAME=${0##*/}

homefiles="
"
# .local
files="
bin
bashrc
bash_profile
gitconfig
zshrc
vimrc
tmux.conf
tmuxinator
profile
tmux
xterm-256color-italic.terminfo
dotfile_overrides/zshrc_local
dotfile_overrides/profile.local
"
gits="
gruvbox
oh-my-zsh
"

function copy_files {
    echo "Deleting and remaking homedir directory ($HOMEDIR)"
    # Nuke my homedir directory
    rm -rf $HOMEDIR

    # Make a new homedir directory
    mkdir $HOMEDIR

    # Change to script directory
    cd $DIR || return

    # Copy over this updater to HOMEDIR
    echo "Copying $SCRIPT_NAME ($SCRIPT_NAME -> $HOMEDIR/$SCRIPT_NAME)"
    cp "$SCRIPT_NAME" "$HOMEDIR"

    # Copy over each file in files to HOMEDIR
    for file in $files; do
        if [[ -f $file || -d $file ]]; then
            file_name=${file##*/}
            echo "Copying $file ($DIR/$file -> $HOMEDIR/.$file_name)"
            cp -r $DIR/"$file" $HOMEDIR/."$file_name"
        fi
    done

    # Copy over each file in homefiles to HOMEDIR
    for file in $homefiles; do
        if [[ -f ~/$file || -d ~/$file ]]; then
            file_name=${file##*/}
            echo "Copying $file ($file -> $HOMEDIR/$file_name)"
            cp -r ~/"$file" $HOMEDIR/"$file_name"
        fi
    done

    # Copy over each git repo in gits without the .git folder to HOMEDIR
    for repo in $gits; do
        if [[ -d $repo ]]; then
            repo_name=${repo##*/}
            echo "Copying $repo without .git folder ($DIR/$repo -> $HOMEDIR/.$repo_name)"
            pushd $DIR/"$repo" || return
            mkdir $HOMEDIR/."$repo_name"
            git archive master | tar -x -C $HOMEDIR/."$repo_name"
            popd || return
        fi
    done
}

copy_files
