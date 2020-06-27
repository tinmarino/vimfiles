# Init
pg=()

pg+=(
# Operational
git
gitk
tmux
bash-completion
vlc
vim-gnome
exuberant-ctag
ssh
mosh
xterm
fzf

# Language
jupyter-console
perl
bash
texlive-latex-extra

# Program
gimp
firefox
pdftk
imagemagick
pandoc

# System
ubuntu-drivers-common
gnome-terminal
wine
)

# Print out
echo -n "sudo apt install "
for prog in "${pg[@]}" ; do echo -n "$prog " ; done
echo
