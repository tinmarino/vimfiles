#!/usr/bin/env bash

# Run windows cmd: https://stackoverflow.com/questions/18641864/git-bash-shell-fails-to-create-symbolic-links


# Get script path
# shellcheck disable=SC2164
scriptpath="$( cd "$(dirname "$0")"; pwd -P )"
echo "[*] Dotfile path is $scriptpath"

# Get OS
uname=$(uname -a)
uname=${uname,,}
case $uname in
  *"android"*)
    export os="termux";;
  *"linux"*)
    export os="unix";;
  *"mingw"*)
    export os="windows";;
esac
echo "[*] OS is $os"


# Helper: 
convert_path_to_windows() {
  echo "$1" | sed 's/^\///' | sed 's/\//\\/g' | sed 's/^./\0:/'
}

# Helper: https://stackoverflow.com/questions/13701218/windows-path-to-posix-path-conversion-in-bash
convert_path_to_unix() {
  echo "/$1" | sed -e 's/\\/\//g' -e 's/://'
}

# Helper: Make symbolic link
try_link() {
    target="$1"
    link="$2"
    if [[ -f "$link" || -L "$link" ]] ; then
        echo "[-] $link already exists"
	unlink "$link"
    else
        if [ "$os" = "windows" ] ; then
            target=$(convert_path_to_windows "$target")
            link=$(convert_path_to_windows "$link")
            cmd <<< "mklink $link $target" > /dev/null
            echo "[?] $link may be created, ARE YOU ADMIN ?"
        else
            ln -s "$target" "$link" && echo "[+] $link created"
        fi
    fi
}

# Trash
mkdir "$HOME/.Trash"

# Git
try_link "$scriptpath/gitconfig"  ~/.gitconfig
try_link "$scriptpath/gitignore"  ~/.gitignore

# Tmux
try_link "$scriptpath/tmux.conf"  ~/.tmux.conf

# Termux
[ -d ~/.termux ] || mkdir ~/.termux
try_link "$scriptpath/termux.properties" ~/.termux/termux.properties

# Vim
try_link "$scriptpath/vimrc" ~/.vimrc
# # Create undodir
undo_path=$(dirname "$scriptpath")/undo
if [ -d "$undo_path" ] ; then
    echo "[-] $undo_path already exists"
else
    mkdir "$undo_path"
    echo "[+] $undo_path created"
fi
try_link "$scriptpath/vimspector.json" ~/.vimspector.json

# Python
mkdir ~/.ipython
mkdir ~/.ipython/profile_default
try_link "$scriptpath/ipython_config.py" ~/.ipython/profile_default/ipython_config.py
try_link "$scriptpath/ipython_kernel_config.py" ~/.ipython/profile_default/ipython_kernel_config.py
mkdir ~/.jupyter
try_link "$scriptpath/jupyter_console_config.py" ~/.jupyter/jupyter_console_config.py
try_link "$scriptpath/pylint.py" ~/.pylintrc

# Perl
try_link "$scriptpath/replyrc" ~/.replyrc
try_link "$scriptpath/perlrc.pl" ~/.perlrc.pl
try_link "$scriptpath/Tool.pm" ~/Software/Perl/Lib/Tool.pm

# Bash
try_link "$scriptpath/bash_profile.sh" ~/.bash_profile
try_link "$scriptpath/bash_aliases.sh" ~/.bash_aliases.sh
try_link "$scriptpath/bashrc.sh" ~/.bashrc
try_link "$scriptpath/inputrc" ~/.inputrc
try_link "$scriptpath/Xdefaults" ~/.Xdefaults
try_link "$scriptpath/Xresources" ~/.Xresources
xrdb ~/.Xresources

# Alacritty
try_link "$scriptpath/alacritty.yml" ~/.alacritty.yml

# GDB
try_link "$scriptpath/gdbinit.gdb" ~/.gdbinit
