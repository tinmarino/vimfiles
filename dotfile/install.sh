function try_link {
    [ -f $2 ] \
        && echo "FF : $2 exists" \
        || ( ln -s $1 $2 && echo "OK : $2 created" )
}

# Git
try_link ~/.vim/dotfile/gitconfig  ~/.gitconfig

# Tmux
try_link ~/.vim/dotfile/tmux.conf  ~/.tmux.conf

# Termux
[ -d ~/.termux ] || mkdir ~/.termux
try_link ~/.vim/dotfile/termux.properties ~/.termux/termux.properties

# Vim
try_link ~/.vim/dotfile/vimrc ~/.vimrc

# Perl
try_link ~/.vim/dotfile/replyrc ~/.replyrc
try_link ~/.vim/dotfile/perlrc.pl ~/.perlrc.pl
try_link ~/.vim/dotfile/Tool.pm ~/Software/Perl/Lib/Tool.pm

# Bash
try_link ~/.vim/dotfile/bash_aliases.sh ~/.bash_aliases.sh
try_link ~/.vim/dotfile/bashrc ~/.bashrc
try_link ~/.vim/dotfile/inputrc ~/.inputrc
