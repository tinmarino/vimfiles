#!/usr/bin/env bash
: '
This aims to be executed with a docker image called bash_image

With git and vim

See bash.dockerfile installed by a github action to exploit cache
'

bash_test(){
  : 'Main'
  local -i res=0
  
  git clone --depth=10 -j8 https://github.com/tinmarino/vimfiles ~/.vim || return 10

  bash ~/.vim/dotfile/install.sh || return 11
  
  return "$res"
}


if ! (return 0 2>/dev/null); then
  echo "--> $0 starting with $*." >&2
  bash_test "$@"; res=$?
  echo "<-- $0 returned with $res." >&2
  exit "$res"
fi
