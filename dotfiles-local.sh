#!/bin/bash

# Check if running interactively
if [ -t 0 ]; then
    # Interactive session
    interactive=1
else
    # Non-interactive session (e.g. Coder workspace initialization)
    interactive=0
fi
if [ -f "$HOME/.dotfiles-dir" ]; then
    source "$HOME/.dotfiles-dir"
else
    echo "Dotfiles repository not set in $HOME/.dotfiles-dir"
    echo "Please run ./install.sh in dotfiles repository and exit to create ~/.dotfiles-dir"
fi

dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" # dotfiles-local repository directory
locals_dir="$dir/dependencies/dotfiles-local"
config_dir="$locals_dir"/config
dotfiles_packages_root="$DOTFILES_DIR/packages"

package_lists="
apt
arch
aur
brew
flatpak
pipx
snap
"

home_files="
zshrc_local
profile.local
"

configs="
i3/config.local
"

source "$DOTFILES_DIR/functions.sh"
cd "$locals_dir"

if [[ $(program_installed git) == 0 ]]; then
    echo "git not installed, please install and rerun"
    exit 1
fi

# TODO: Make sure submodule is cloned

# Ask machine name and set branch
if [ -n "$1" ]; then
    branch_name="$1"
else
    if [ "$interactive" == 0 ]; then
        echo "Non-interactive sessions must specify a branch name. Rerun with:"
        echo "> ./dotfiles-local.sh {branch_name}"
        exit 1
    fi
    echo -n "What machine name would you like to use for this branch? [$(hostname)] "
    read response
    if [ -z "$response" ]; then
        # echo "Please enter a valid name for this machine's branch. Rerun with:"
        # echo "> ./dotfiles-local.sh {branch_name}"
        # exit 1
        branch_name="$(hostname)"
    else
        branch_name="$response"
    fi
fi

# Check if already on branch
if [ $(git rev-parse --abbrev-ref HEAD) == "$branch_name" ]; then
    echo "Already on branch $branch_name"
else
    # Check if branch already exists
    git ls-remote --exit-code --heads origin "$branch_name" > /dev/null
    if [ $? == 0 ]; then
        echo "$branch_name branch exists, checking out existing branch"
        # TODO: This doesn't work if the local branch already exists
        # Should just check if we're already on the branch
        git checkout -b "$branch_name" "origin/$branch_name"
    else
        echo "$branch_name branch doesn't exist yet, creating and checking out new branch"
        git checkout main
        git checkout -b "$branch_name"
    fi
fi

# Move any existing local installation script into repo and symlink out
skip=0
if [ -f "$DOTFILES_DIR/install_local.sh" ]; then
    echo "Discovered local installation script install_local.sh"
    # Check if file is a symlink
    if [[ -L "$DOTFILES_DIR/install_local.sh" ]]; then
        # TODO: Make sure that it's actually linked from here and not somewhere else
        echo "Skipping: install_local.sh because file already linked"
        skip=1
    elif [[ -f "$DOTFILES_DIR/install_local.sh" ]]; then
        if [[ -f "$locals_dir/install_local.sh" ]]; then
            # TODO: Do we want to overwrite what's in dotfiles-local?
            echo "Replacing copy in dotfiles-local with local copy and symlinking back"
        else
            echo "Moving into dotfiles-local and symlinking back"
        fi
        mv "$DOTFILES_DIR/install_local.sh" "$locals_dir/"
    fi
fi
if [[ $skip == 0 ]] && [[ -f "$locals_dir/install_local.sh" ]]; then
    ln -s "$locals_dir/install_local.sh" "$DOTFILES_DIR/install_local.sh"
elif [[ skip == 0 ]]; then
    echo "No install_local.sh script found in $locals_dir or $DOTFILES_DIR. Skipping"
fi
echo ""

# Move any existing local packages into repo and symlink out
while IFS= read -r package_manager || [[ -n $package_manager ]]; do
    if [[ "$package_manager" == '#'* || -z "${package_manager// }" ]]; then
        continue
    fi
    skip=0
    if [ -f "$dotfiles_packages_root/$package_manager.local" ]; then
        echo "Discovered local packages for $package_manager"

        # Check if file is a symlink
        if [[ -L "$dotfiles_packages_root/$package_manager.local" ]]; then
            # TODO: Make sure that it's actually linked from here and not somewhere else
            echo "Skipping: $package_manager.local because file already linked"
            skip=1
        elif [[ -f "$dotfiles_packages_root/$package_manager.local" ]]; then
            if [[ -f "$locals_dir/packages/$package_manager.local" ]]; then
                # TODO: Do we want to overwrite what's in dotfiles-local?
                echo "Replacing copy in dotfiles-local with local copy and symlinking back"
            else
                echo "Moving into dotfiles-local and symlinking back"
            fi
            mv "$dotfiles_packages_root/$package_manager.local" "$locals_dir/packages/"
        fi
    fi
    if [[ $skip == 0 ]] && [[ -f "$locals_dir/packages/$package_manager.local" ]]; then
        ln -s "$locals_dir/packages/$package_manager.local" "$dotfiles_packages_root/$package_manager.local"
    elif [[ skip == 0 ]]; then
        echo "No $package_manager.local found in $locals_dir/packages or $dotfiles_packages_root. Skipping"
    fi
    echo ""
done < <(printf '%s' "$package_lists")

# Move any existing local dotfiles into repo and symlink out
# TODO: These only symlink to dotfiles, they don't symlink to the actual locations. Should probably fix that
while IFS= read -r config || [[ -n $config ]]; do
    if [[ "$config" == '#'* || -z "${config// }" ]]; then
        continue
    fi
    skip=0
    if [ -f "$HOME/.$config" ]; then
        echo "Discovered local dotfile ~/.$config"

        # Check if file is a symlink
        if [[ -L "$HOME/.$config" ]]; then
            # TODO: Make sure that it's actually linked from here and not somewhere else
            echo "Skipping: ~/.$config because file already linked"
            skip=1
        elif [[ -f "$HOME/.$config" ]]; then
            if [[ -f "$locals_dir/config/$config" ]]; then
                # TODO: Do we want to overwrite what's in dotfiles-local?
                echo "Replacing copy in dotfiles-local with local copy and symlinking back"
            else
                echo "Moving into dotfiles-local and symlinking back"
            fi
            mv "$HOME/.$config" "$config_dir/$config"
        fi
    fi
    if [[ $skip == 0 ]] && [[ -f "$locals_dir/config/$config" ]]; then
        ln -s "$locals_dir/config/$config" "$HOME/.$config"
    elif [[ skip == 0 ]]; then
        echo "No $config file found in $locals_dir/config or $HOME . Skipping"
    fi
    echo ""
done < <(printf '%s' "$home_files")

# Move any existing files in .config into repo and symlink out
while IFS= read -r config || [[ -n $config ]]; do
    if [[ "$config" == '#'* || -z "${config// }" ]]; then
        continue
    fi
    skip=0
    if [ -f "$HOME/.config/$config" ]; then
        echo "Discovered local dotfile ~/.config/$config"

        # Check if file is a symlink
        if [[ -L "$HOME/.config/$config" ]]; then
            # TODO: Make sure that it's actually linked from here and not somewhere else
            echo "Skipping: ~/.config/$config because file already linked"
            skip=1
        elif [[ -f "$HOME/.config/$config" ]]; then
            if [[ -f "$locals_dir/config/$config" ]]; then
                # TODO: Do we want to overwrite what's in dotfiles-local?
                echo "Replacing copy in dotfiles-local with local copy and symlinking back"
            else
                echo "Moving into dotfiles-local and symlinking back"
            fi
            mv "$HOME/.config/$config" "$config_dir/$config"
        fi
    fi
    if [[ $skip == 0 ]] && [[ -f "$locals_dir/config/$config" ]]; then
        ln -s "$locals_dir/config/$config" "$HOME/.config/$config"
    elif [[ skip == 0 ]]; then
        echo "No $config file found in $locals_dir/config or $HOME/.config . Skipping"
    fi
    echo ""
done < <(printf '%s' "$configs")

# sync dotfiles to git
if [ "$interactive" == 0 ]; then
    echo "Syncing local dotfiles to git branch. [$branch_name]"
else
    echo -n "Would you like to push dotfiles-local to git? [$branch_name] (y/n) "
    read response
    if [[ $response != 'y' ]] && [[ $response != 'Y' ]]; then
        exit 0
    fi
fi
git add -A
git commit -m "Automated sync"
git push origin "$branch_name"
echo "dotfiles-local synced to git. [$branch_name]"

cd -
