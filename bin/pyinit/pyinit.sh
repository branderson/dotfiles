#!/bin/bash

# Store execution directory
dir=$(pwd)

# Find and store script directory
src="${BASH_SOURCE[0]}"
while [ -h "$src" ]; do # resolve $SOURCE until the file is no longer a symlink
    script_dir="$( cd -P "$( dirname "$src" )" && pwd )"
    src="$(readlink "$src")"
    # if $SOURCE was a relative symlink, resolve it relative to the path the symlink file was located
    [[ $src != /* ]] && SOURCE="$script_dir/$src"
done
script_dir="$( cd -P "$( dirname "$src" )" && pwd )"

# Return to execution directory
cd $dir

# Ensure exactly one argument supplied
if [ "$#" -ne 1 ]; then
    echo "Please supply a project name"
    exit
fi

# Make project directory and move to it
mkdir "$1" 
cd "$1"

# Make project subdirectories
mkdir bin "$1" tests docs

touch "$1"/__init__.py
touch tests/__init__.py
cp $script_dir/setup.py .
cp $script_dir/tests.py tests/"$1"_tests.py
