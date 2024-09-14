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
curl
wget

fzf
ripgrep  # faster find

python3
python3-pip

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
yamllint

# Language
jupyter-console python3-pip
perl
bash
npm

# LaTex
texlive-full latex-mk latexmk
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

# TODO
# pip3 install vim-vint

# npm install -g diff-so-fancy

# Print out
run(){
  printf %s "\nRunning: $*"
  "$@"
  return $?
}


for prog in "${android[@]}"; do
  run apt install --upgrade --yes "$prog"
done
