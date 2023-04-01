#!/usr/bin/env bash
: '
This aims to be executed with a docker image called bash_image

With git and vim

See bash.dockerfile installed by a github action to exploit cache
'

declare -gi gi_err=0

assert(){
  local msg=''
  local -i res=0

  if [[ "$1" == "$2" ]]; then
    msg="[+] '$2' is equal to '$1'"
    res=0
  else
    msg="\e[31m[-] '$2' is not equal to '$1'\e[0m"
    (( gi_err++ ))
    res=1
  fi
  echo -e "$msg"
  return "$res"
}


bash_test(){
  : 'Main

  TODO handle if .vim or .bashrc is already here
  -- but do not risk deleting if run 
  '
  local -i res=0
  
  echo -e "\n--> Cloning"
  git clone --depth=10 -j8 https://github.com/tinmarino/vimfiles ~/.vim

  echo -e "\n--> Installing"
  bash ~/.vim/dotfile/install.sh || ((res++))

  echo -e "\n--> Sourcing"
  PS1='\w$\n'
  source ~/.bashrc
  env

  echo -e "\n--> Test 1"
  assert "$HOME/.vim" "$V" || ((res++))
  
  return "$res"
}


if ! (return 0 2>/dev/null); then
  echo "--> $0 starting with $*." >&2
  bash_test "$@"; res=$?
  echo "<-- $0 returned with status=$res and failure number=$gi_err" >&2
  exit "$res"
fi
