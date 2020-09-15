#!/bin/bash
# Synchronize wikis, and .vim

source "$(dirname "${BASH_SOURCE[0]}")/_shellutil.sh"

s_error_msg=''

_usage(){
  `# Print this message`
  print_title "Synchronization"
  print_usage_fct
}

__wget(){
  check="$1"
  check="${check%%.tar.bz2}"
  if [[ -e "$check" ]]; then
    echo "[*] $check already exists"
    return
  else
    echo "Info: $check not existing => Dowloading"
  fi
  ((n++))
  wget "$2" -O "$1" || { echo -e "[-] $1 ${cbad}Download FAILED" && return 1; }

  if [[ "$1" =~ .tar.bz2$ ]]; then
    directory="$(dirname "$1")"
    tar -xvf "$1" --directory "$directory" || { echo -e "[-] $1 ${cbad}Failed Untar" && return 1; }
    unlink "$1"
  fi

  ((ok++))
  echo "[+] $1 Succeed Download"
}

# Get online documentation
function __site(){
  echo -e "${ctitle}--->  SITES  =================================================\e[0m"
  __wget "$1/Bash/bash_reference.html" "https://www.gnu.org/software/bash/manual/bash.html"
  __wget "$1/Bash/bash_advanced_bash_scripting.html" "https://tldp.org/LDP/abs/html/abs-guide.html"
  __wget "$1/Python/python-3.8.5-docs-html.tar.bz2" "https://docs.python.org/3.8/archives/python-3.8.5-docs-html.tar.bz2"
}

# Sychrnonize argument folder
function __base(){
  # 1: Local Diretory
  # 2: Remote URL
  # 3: Sync command: ex: "pull --rebase"
  # Set vars
  title=$(basename -- "$1")
  title=${title^^}
  ((ret=0))

  # Log && Pushd
  # Bold purple
  echo -e "${ctitle}--->  $title  =================================================\e[0m"
  mkdir "$1" 2> /dev/null && echo "[*] Created directory $1"
  pushd "$1" > /dev/null || {
    echo "\e[E] Cannot pushd $1"
    return 1
  }

  # Create git repo
  if ! [ -d .git ]; then
    git clone "$2" . && echo '[*] Initialised clone'
  fi

  # Git sync
  if [[ -z "$3" ]]; then
    git add .
    message="___ <- sync_wiki.sh: Modified: $(git diff --name-only --cached | sed ':a;N;$!ba;s/\n/, /g')"
    git commit -m "$message"
    git pull --rebase
    if git push --all ; then
      echo -e "[+] push OK"
    else
      echo -e "[-] ${cbad}push FAILED\e[0m"
      s_error_msg+="<- Failed: $1\n"
      ((ret=1))
    fi
  else
    if $3; then
      echo -e "[+] $3 OK"
    else
      echo -e "[-] ${cbad}$3 FAILED\e[0m"
      s_error_msg+="<- Failed: $1\n"
      ((ret=1))
    fi
  fi

  # Popd && Ret
  popd > /dev/null || {
    echo "\e[E] Cannot popd"
    return 1
  }
  return $ret
}

# Proxy counting errors
__sync(){
  ((n++)); __base "$1" "$2" "$3"  && ((ok++))
}

((ok=0))
((n=0))
ctitle="\e[1m\e[38;5;13m"
cend="\e[1m\e[38;5;39m"
cgood="\e[1m\e[38;5;46m"
cbad="\e[1m\e[38;5;196m"

## Bold blue
echo -e "${cend}---> Synchronizing from internet\e[0m"

site(){
  `# Site: Sync ~/wiki/html folder: dump of pages`
  __site ~/wiki/html
}
wiki(){
  `# Wiki: Sync ~/wiki/ default wiki: set by default, reset by -r`
  __sync ~/wiki/todo      https://gitlab.com/tinmarino/todo.git
  __sync ~/wiki/wiki      https://github.com/tinmarino/wiki
  __sync ~/wiki/alki      https://gitlab.com/tinmarino/alki.git
}

rosetta(){
  `# Sync Rosetta Stone code ~/wiki/rosetta`
  __sync ~/wiki/rosetta   https://github.com/acmeism/RosettaCodeData "git pull --rebase"
}
html(){
  `#Html: Sync ~/wiki/*_html generated folders`
  __sync ~/wiki/wiki_html https://github.com/tinmarino/wiki_html
  __sync ~/wiki/alki_html https://gitlab.com/tinmarino/alki_html.git
}
vim(){
  `# Vim: Sync ~/.vim folder`
  # shellcheck disable=SC2154
  __sync "$v"             https://github.com/tinmarino/vimfiles
}
all(){
  `# All: Sync all except vim`
  wiki; rosetta; html; site;
}



get_fct_dic
call_fct_arg "$@"

cout="$cbad"
if ((ok == n)); then
  cout="$cgood"
fi
echo "$s_error_msg"

echo -e "${cend}<--- Synchronization finished with: ${cout}$ok/$n\e[0m"

# vim:sw=2:ts=2:
