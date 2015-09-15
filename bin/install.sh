#!/bin/bash
#

dir=~/dotfiles
olddir=~/dotfiles/bak
files="vimrc vim gitconfig tmux.conf"

echo "Creating $olddir for backup ..."
mkdir -p $olddir

cd $dir

for file in $files; do
    if [ -f  ~/.$file ]; then
        mv ~/.$file $olddir/$file
    fi

    echo "Creating symlink to $file in home directory"
    ln -s $dir/$file ~/.$file
done

brew_install () {
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}


