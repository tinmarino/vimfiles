#!/bin/bash

create_dir() {
  cd ~ && mkdir wiki \
    && echo '[+] ~/wiki created' \
    || echo '[-] ~/wiki not created already exists ?'
  cd ~/wiki && mkdir wiki wiki_html todo todo_html html \
    && echo '[+] all wiki dir created' \
    || echo '[-] some wiki dir not created already exists ?'
}

make_clone() {
  dir=$1
  url=$2
  echo -e "\n[*] Working with $dir"
  [ -d $dir ] \
    && cd $dir \
    && git clone  $url . \
    && echo "[+] $dir cloned from $url" \
    || echo "[-] $dir not cloned maybe create the dir with function create_dir in this file"
}

pushd ~
mkdir .Trash

create_dir
make_clone ~/wiki/wiki https://gitlab.com/tinmarino/vimwiki.git
make_clone ~/wiki/wiki_html https://gitlab.com/tinmarino/Wiki_Html.git  
make_clone ~/wiki/todo https://gitlab.com/tinmarino/todo.git 
make_clone ~/wiki/html https://gitlab.com/tinmarino/html.git

popd
