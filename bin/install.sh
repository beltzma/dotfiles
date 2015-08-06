#!/bin/bash
#

dir=~/.dotfiles
olddir=~/.dotfiles/bak
files="vimrc vim gitconfig tmux.conf"

echo "Creating $olddir for backup ..."
mkdir -p $olddir

cd $dir

for file in $files; do
    mv ~/.$file $olddir
    echo "Creating symlink to $file in home directory"
    ln -s $dir/$file ~/.$file
done



