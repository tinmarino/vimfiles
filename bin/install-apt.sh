#!/usr/bin/env bash
# Print APT commands to install for myself => feel at home (vim, bash-completion)
#
# TODO vim and fzf from git
# TODO sudo apt install -o Dpkg::Options::="--force-overwrite" bat ripgrep

# Packages to install also on termux
android=(
# Operational
git
tmux
vim

fzf
ripgrep  # faster find

python3

ssh
sshd
)

pg+=(
# Operational
gitk
tmux
bash-completion
vlc
vim-gtk  # For system clipboard
exuberant-ctags
mosh
xterm

# Fzf stuff
# See: https://github.com/sharkdp/bat/issues/938 
bat  # syntax hi in fzf
fdfind  # faster find but not used

# Linters
shellcheck

# Language
jupyter-console python3-pip
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
zeal

# System
ubuntu-drivers-common
gnome-terminal
wine
linux-headers-generic
)

# npm install -g diff-so-fancy

# Print out
echo -n "sudo apt install "

for prog in "${android[@]}"; do
  echo -n "$prog " ; done
echo
