# Vimfiles and dotfiles

Commands to run in vimfiles directory (`~/vim`):

```sh
# Get me
git clone --recurse-submodules -j8 https://github.com/tinmarino/vimfiles ~/.vim

# Sync submodules
pushd ~/.vim
git submodule update --init  --recursive --remote --jobs 8
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

# Must install (Windows)

* Cmder
* Gvim
* Python3 (choose good version)
