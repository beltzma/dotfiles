#!/bin/bash
#

dir=~/dotfiles
olddir=~/dotfiles/bak-$( date +%d-%m-%Y-%H-%M )
files="vimrc gitconfig tmux.conf zshrc"

function brew_install() {
    echo "brew wird nachinstalliert"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

function brew_update() {
    brew update
    brew upgrade `brew outdated`
}


function brew_depend() {
    if [ ! -x /usr/local/bin/brew ]; then
        brew_install
    fi
    echo "brew aktualisieren..."
    brew_update
    for pkg in wget tmux zsh reattach-to-user-namespace ssh-copy-id; do
        if brew list -1 | grep -q "^${pkg}\$"; then
            echo "Package '$pkg' is installed"
        else
            echo "Package '$pkg' is NOT installed, will do"
            brew install $pkg
        fi
    done

}

function oh_my_zsh_install() {
    if [ ! -d ~/.oh-my-zsh ]; then
        echo "installing oh-my-zsh ..."
        git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    fi
}
function vim_install() {
    if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
        vim +PluginInstall +qall
        cd ~/.vim/bundle/YouCompleteMe
        ./install.py --clang-completer
    fi
}

function linux_pkg_install {
    if [ $REDHAT ]; then
        /usr/bin/sudo $PKG_MGT list installed $1 
        if [ $? -ne 0 ]; then
            /usr/bin/sudo $PKG_MGT install -y $1
        fi
    fi

}
case `uname` in
    Darwin)
       brew_depend
        ;;
    Linux)
        if [ -x /usr/bin/yum ]; then 
            REDHAT=true
            PKG_MGT=yum
            if [ -x /usr/bin/dnf ]; then # Fedora >= 22
                PKG_MGT=dnf
            fi
            /usr/bin/sudo $PKG_MGT -y groupinstall "Development Tools"
            /usr/bin/sudo $PKG_MGT -y install gcc-c++
            /usr/bin/sudo $PKG_MGT -y install python-devel 
        fi
        for PKG in wget tmux zsh vim cmake; do
            linux_pkg_install $PKG
        done
        ;;
    FreeBSD)
        if [ ! -x /usr/sbin/pkg ]; then
            echo "FreeBSD scheinbar nicht vollständig installiert"
            exit
        fi
        if [ ! -x /usr/local/bin/sudo ]; then
            echo "sudo nicht installiert"
            exit
        fi
        for PKG in wget tmux zsh vim; do
            /usr/local/bin/sudo pkg query %n $PKG 
            if [ $? -ne 0 ]; then
                /usr/local/bin/sudo pkg install -y $PKG
            fi
        done
        ;;
esac

oh_my_zsh_install

echo "Creating $olddir for backup ..."
mkdir -p $olddir

cd $dir
mv ~/.vim $olddir/vim

for file in $files; do
    if [ -f  ~/.$file ]; then
        mv ~/.$file $olddir/$file
    fi

    echo "Creating symlink to $file in home directory"
    ln -s $dir/$file ~/.$file
done

vim_install
