# Vimfiles and dotfiles

[![CI: Vader](https://github.com/tinmarino/vimfiles/workflows/Vader/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/vader.yml)
[![CI: Bash](https://github.com/tinmarino/vimfiles/workflows/Bash/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/bash.yml)
<br/>
[![CI: Vint](https://github.com/tinmarino/vimfiles/workflows/Vint/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/vint.yml)
[![CI: Typos](https://github.com/tinmarino/vimfiles/workflows/Typos/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/typos.yml)
[![CI: Yamllint](https://github.com/tinmarino/vimfiles/workflows/Yamllint/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/yamllint.yml)
[![CI: Shellcheck](https://github.com/tinmarino/vimfiles/workflows/Shellcheck/badge.svg)](https://github.com/tinmarino/vimfiles/actions/workflows/shellcheck.yml)

---

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

# Add plugin

```bash
git submodule add https://github.com/jpalardy/vim-slime
```


# Must install (Windows)

* Cmder
* Gvim
* Python3 (choose good version)
