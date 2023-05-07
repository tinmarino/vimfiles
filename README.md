# Vimfiles and dotfiles

Execute: [![CI: Vader](https://github.com/tinmarino/vimfiles/workflows/Vader/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/vader.yml)
[![CI: Bash](https://github.com/tinmarino/vimfiles/workflows/Bash/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/bash.yml)
<br/>
Lint: [![CI: Vint](https://github.com/tinmarino/vimfiles/workflows/Vint/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/vint.yml)
[![CI: Typos](https://github.com/tinmarino/vimfiles/workflows/Typos/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/typos.yml)
[![CI: Yamllint](https://github.com/tinmarino/vimfiles/workflows/Yamllint/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/yamllint.yml)
[![CI: Shellcheck](https://github.com/tinmarino/vimfiles/workflows/Shellcheck/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/shellcheck.yml)
[![CI: Pylint](https://github.com/tinmarino/vimfiles/workflows/Pylint/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/pylint.yml)

---

| Chapter              | Content  |
| ---                  | --- |
| [Install](#install) | install my dotfiles on other computer, git and bash |
| [Git alias](#git)  | demo on how to use my git numbered alias |


# Install <a name="install"></a>


Commands to run in vimfiles directory (`~/vim`):

```sh
# Get me: --depth=number of commit, -j : number of thread
git clone --recurse-submodules --depth=10 -j8 https://github.com/tinmarino/vimfiles ~/.vim

# Sync submodules
pushd ~/.vim
git submodule update --init --recursive --remote --force --jobs 8
git submodule foreach "git pull origin master"
git submodule foreach "git reset HEAD ."
git submodule foreach "git checkout -- ."
popd

# Install dotfiles
bash ~/.vim/dotfile/install.sh

# Install wikis
bash ~/.vim/bin/deploy_wiki.sh

# Install YouCompleteMe
git clone https://github.com/ycm-core/YouCompleteMe ~/.vim/pack/bundle/opt/youcompleteme
pushd ~/.vim/pack/bundle/opt/youcompleteme
git submodule update --init --recursive
python3 install.py --clangd-completer --ts-completer --java-completer
popd
```

Add plugin

```bash
git submodule add https://github.com/jpalardy/vim-slime
```

Must install (Windows)

* Cmder
* Gvim
* Python3 (choose good version)

# Git workflow for Josito <a name="git"></a>

Demo to show the use of numbering in git status in order to add by number and not having to copy/paste the full path.
Those quick alias are defined [here in my gitconfig](https://github.com/tinmarino/vimfiles/blob/9e82a04fb98453196528421238a0895f2cb79b54/dotfile/gitconfig#L32-L74)

[![asciicast](https://asciinema.org/a/583025.svg)](https://asciinema.org/a/583025)

```bash
# Get me
wget -O .gitconfig https://github.com/tinmarino/vimfiles/blob/master/dotfile/gitconfig

g s      # Status <= small as used a lot (huffman rule), see also a for add or c for commit -m
type g   # Also used a lot, g=>git v=>vim, py=>python
gs       # I often forget to type the space
type gs  # This is to overide ghostscript, but where there is no command, I have a better trick

# Command not found trick
g qs     # Quick status
gqs      # See, all my git aliases work without the space to separe from the g command but I did not redefine bash alias for each git alias, try to catch the trick
type command_not_found_handle
unset -f command_not_found_handle
gqs      # Oups not working anymore
exec bash  # And we're back

g qd 3  # Quick diff
g qd 1..3,5  # Accept any perl expresion
g qe 3  # Quick edit, with vim + fugitive so I can select lines to add with TUI

gc "Doc: Add placeholder for git show of"

g qd 4..9

g qd 9
g qa 9  # Quick Add <= OK I want it
gc "VimRc: add shelcheck ignore diretives"

# Admire your work without gitk small font
fgl     # Fuzzy Git Log

gf      # Fetch (and rebase above)
g h     # PusH

echo Bye
```
