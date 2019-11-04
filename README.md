# Vimfiles and dotfiles


In vimfiles directory (`~/vim`):

```sh
# Get me
git clone --recurse-submodules -j8 https://github.com/tinmarino/vimfiles .vim

# Sync submodules
git submodule update --recursive --remote --jobs 8
git submodule foreach "git reset HEAD ."
git submodule foreach "git checkout -- ."

# Install dotfiles
bash dotfile/install.sh

# Install wikis
bash bin/deploy_wiki.sh
```

# Must install (Windows)

* Cmder
* Gvim
* Python3 (choose good version)
