#!/usr/bin/env bash
# TODO vim and fzf from git
# TODO sudo apt install -o Dpkg::Options::="--force-overwrite" bat ripgrep

# Init
pg=()

pg+=(
# Operational
git
gitk
tmux
bash-completion
vlc
vim-gtk  # For system clipboard
exuberant-ctags
ssh
mosh
xterm

# Fzf stuff
# See: https://github.com/sharkdp/bat/issues/938 
fzf
bat  # syntax hi in fzf
ripgrep  # faster find
fdfind  # faster find but not used

# Linters
shellcheck

# Language
python3 jupyter-console python3-pip
perl
bash
npm

# LaTex
texlive-latex-extra latex-mk latexmk
pandoc
pdf2svg

# Program
gimp
firefox
pdftk
imagemagick
virtual-box

# System
ubuntu-drivers-common
gnome-terminal
wine
linux-headers-generic
)

# npm install -g diff-so-fancy

# Print out
echo -n "sudo apt install "
for prog in "${pg[@]}" ; do echo -n "$prog " ; done
echo
