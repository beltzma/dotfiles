#!/bin/bash
#

dir=~/dotfiles
olddir=~/dotfiles/bak
files="vimrc vim gitconfig tmux.conf"

function brew_install() {
    echo "brew wird nachinstalliert"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function brew_depend() {
    if [ ! -x /usr/local/bin/brew ]; then
        brew_install
    fi
    echo "brew aktualisieren..."
    brew update
    for pkg in wget tmux zsh reattach-to-user-namespace; do
        if brew list -1 | grep -q "^${pkg}\$"; then
            echo "Package '$pkg' is installed"
        else
            echo "Package '$pkg' is NOT installed, will do"
            brew install $pkg
        fi
    done

    if [ ! -d ~/.oh-my-zsh ]; then
        git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    fi
}

case `uname` in
    Darwin)
        brew_depend
        ;;
    Linux)
        if [ ! -x /usr/bin/yum ]; then 
            echo "nicht Redhat basiertes System"
            echo "Bitte entsprechende Pakete installieren!"
        fi
        ;;
esac
        

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


