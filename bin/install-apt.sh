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

# --- Auditoria dotfiles: paquetes que la config REALMENTE usa y faltaban aca ---
# (el loop de abajo solo instala este array 'android', no 'pg')
bc                # faltaba: tmux.conf compara version con bc (linea 106)
xclip             # faltaba: tmux.conf paste C-p (175) y alias 'clip'
universal-ctags   # faltaba: navegacion de tags en vim (binario: ctags)
perl              # faltaba: alias git qs/qp/qd/qk en gitconfig usan perl
nodejs            # faltaba: coc.nvim (vimrc) necesita node
npm               # faltaba: coc.nvim / diff-so-fancy (npm -g)
bash-completion   # faltaba: bashrc.sh sourcea /etc/bash_completion
bat               # faltaba: bin/fzf_preview usa bat (en ubuntu el binario es batcat)
fd-find           # faltaba: alias fd=fdfind en bash_aliases.sh

python3
python3-pip

ssh
sshd
)

pg=(
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


run apt update

a_ok=()
a_bad=()
for prog in "${android[@]}"; do
  if run apt install --upgrade --yes "$prog"; then
    a_ok+=("$prog")
  else
    a_bad+=("$prog")
  fi
done

echo "Package installed: ${a_ok[*]}"
echo "Package with error: ${a_ok[*]}"
