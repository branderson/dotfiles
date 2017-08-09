#!/bin/bash

DIR=~/dotfiles                    # dotfiles directory
HOMEDIR=~/homedirs/users/bradleya
SCRIPT_NAME=${0##*/}

files="
bashrc
bash_profile
gitconfig
zshrc
vimrc
tmux.conf
tmuxinator
profile
tmux
dotfile_overrides/zshrc_local
dotfile_overrides/profile.local
"
directories="
tmux
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
    cd $DIR

    # Copy over this updater to HOMEDIR
    echo "Copying $SCRIPT_NAME ($SCRIPT_NAME -> $HOMEDIR/$SCRIPT_NAME)"
    cp $SCRIPT_NAME $HOMEDIR

    # Copy over each file in files to HOMEDIR
    for file in $files; do
        if [[ -f $file || -d $file ]]; then
            file_name=${file##*/}
            echo "Copying $file ($DIR/$file -> $HOMEDIR/.$file_name)"
            cp -r $DIR/$file $HOMEDIR/.$file_name
        fi
    done

    # Copy over each directory in directories to HOMEDIR
    # for directory in $directories; do
    #     if [[ -f $directory || -d $directory ]]; then
    #         dir_name=${directory##*/}
    #         echo "Copying $directory ($DIR/$directory -> $HOMEDIR/.$dir_name)"
    #         cp -r $DIR/$directory $HOMEDIR/
    #         mv $HOMEDIR/$dir_name $HOMEDIR/.$dir_name
    #     fi
    # done

    # Copy over each git repo in gits without the .git folder to HOMEDIR
    for repo in $gits; do
        if [[ -d $repo ]]; then
            repo_name=${repo##*/}
            echo "Copying $repo without .git folder ($DIR/$repo -> $HOMEDIR/.$repo_name)"
            pushd $DIR/$repo >/dev/null
            mkdir $HOMEDIR/.$repo_name
            git archive master | tar -x -C $HOMEDIR/.$repo_name
            popd >/dev/null
        fi
    done
}

copy_files
