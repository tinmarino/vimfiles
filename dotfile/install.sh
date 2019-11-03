scriptpath="$( cd "$(dirname "$0")" ; pwd -P )"
echo "[*] Dotfile path is $scriptpath"

function try_link {
    if [ -f $2 ] ; then
        echo "[-] $2 already exists"
    else
        ln -s $1 $2 && echo "[+] $2 created"
    fi
}

# Git
try_link $scriptpath/gitconfig  ~/.gitconfig

# Tmux
try_link $scriptpath/tmux.conf  ~/.tmux.conf

# Termux
[ -d ~/.termux ] || mkdir ~/.termux
try_link $scriptpath/termux.properties ~/.termux/termux.properties

# Vim
try_link $scriptpath/vimrc ~/.vimrc
# # Create undodir
if [ -d $HOME/.vim ] ; then  # I am on gnunix
    vimfile_path=$HOME/.vim
else  # I may be on windows
    vimfile_path=$(which gvim)  # Returns : /c/Users/chio/Work/Program/Gvim/vim81/gvim
    vimfile_path=$(dirname $vimfile_path)
    vimfile_path=$(dirname $vimfile_path)
    vimfile_path="$gvim_path/vimfiles"
fi
undo_path=$vimfile_path/undo
if [ -d $undo_path ] ; then
    echo "[-] $undo_path already exists"
else
    mkdir ~/.vim/undo
    echo "[+] $undo_path created"
fi

# Perl
try_link $scriptpath/replyrc ~/.replyrc
try_link $scriptpath/perlrc.pl ~/.perlrc.pl
try_link $scriptpath/Tool.pm ~/Software/Perl/Lib/Tool.pm

# Bash
try_link $scriptpath/bash_aliases.sh ~/.bash_aliases.sh
try_link $scriptpath/bashrc ~/.bashrc
try_link $scriptpath/inputrc ~/.inputrc
