#!/bin/bash
# This file serves for synchronosation

s_error_msg=''

usage() {
  cat << '    EOF' | sed -e 's/^        //'
    Usage: sync_wiki.sh [OPTIONS]

    Synchronize files in ~/wiki folder

    -h, --help (Help) Print this help message

    -a, --all  (All)  Sync all except vim (if fire: do -av)
    -s, --site (Site) Sync ~/wiki/html folder (dump of pages)
    -v, --vim  (Vim)  Sync ~/.vim folder
    -x, --html (Html) Sync ~/wiki/*_html generated folders
    -w, --wiki (Wiki) Sync ~/wiki/ default wiki (set by default, reset by -r)
    EOF

  exit 0
}

function ssync_wget(){
  check="$1"
  check="${check%%.tar.bz2}"
  if [[ -e "$check" ]]; then
    echo "[*] $check already exists"
    return
  else
    echo "Info: $check not existing => Dowloading"
  fi
  ((n++))
  wget "$2" -O "$1" || { echo -e "[-] $1 ${cbad}Failed Download" && return 1; }

  if [[ "$1" =~ .tar.bz2$ ]]; then
    directory="$(dirname "$1")"
    tar -xvf "$1" --directory "$directory" || { echo -e "[-] $1 ${cbad}Failed Untar" && return 1; }
    unlink "$1"
  fi

  ((ok++))
  echo "[+] $1 Succeed Download"
}

# Get online documentation
function ssync_site(){
  ssync_wget "$1/Bash/bash_reference.html" "https://www.gnu.org/software/bash/manual/bash.html"
  ssync_wget "$1/Bash/bash_advanced_bash_scripting.html" "https://tldp.org/LDP/abs/html/abs-guide.html"
  ssync_wget "$1/Python/python-3.8.5-docs-html.tar.bz2" "https://docs.python.org/3.8/archives/python-3.8.5-docs-html.tar.bz2"
}

# Sychrnonize argument folder
function ssync_base(){
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
  git add .
  message="___ <- sync_wiki.sh: Modified: $(git diff --name-only --cached | sed ':a;N;$!ba;s/\n/, /g')"
  git commit -m "$message"
  git pull --rebase
  if git push --all ; then
    echo -e "[+] push OK"
  else
    echo -e "[-] ${cbad}push failed\e[0m"
    s_error_msg+="<- Failed: $1\n" 
    ((ret=1))
  fi

  # Popd && Ret
  popd > /dev/null || {
    echo "\e[E] Cannot popd"
    return 1
  }
  return $ret
}

# Proxy counting errors
function ssync(){
  ((n++)); ssync_base "$1" "$2"  && ((ok++))
}

((ok=0))
((n=0))
ctitle="\e[1m\e[38;5;13m"
cend="\e[1m\e[38;5;39m"
cgood="\e[1m\e[38;5;46m"
cbad="\e[1m\e[38;5;196m"

((ball=0))
((bsite=0))
((bvim=0))
((bwiki=0))
((bhtml=0))

# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
options=$(getopt \
  -l "all,help,site,vim,html,wiki" \
  -o "ahsvxw" -- "$@")

# set --:
# If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters 
# are set to the arguments, even if some of them begin with a ‘-’.
eval set -- "$options"
echo -n "Args: "
while true; do
  case "$1" in
    -a|--all)
      echo -n "All, "
      ((ball=1))
      ;;
    -h|--help)
      usage
      ;;
    -s|--site)
      echo -n "Site, "
      ((bsite=1))
      ;;
    -v|--vim)
      echo -n "Vim, "
      ((bvim=1))
      ;;
    -w|--wiki)
      echo -n "Wiki, "
      ((bwiki=1))
      ;;
    -x|--html)
      echo -n "Html, "
      ((bhtml=1))
      ;;
    --)
      shift
      break
      ;;
  esac
  shift
done
echo

## Bold blue
echo -e "${cend}---> Synchronizing from internet\e[0m"

# let n++ ; ssync ~/.vim           && let ok++
((ball || bsite))  && ssync_site ~/wiki/html
((ball || bwiki))  && ssync ~/wiki/todo      https://gitlab.com/tinmarino/todo.git
((ball || bwiki))  && ssync ~/wiki/wiki      https://github.com/tinmarino/wiki
((ball || bwiki))  && ssync ~/wiki/alki      https://gitlab.com/tinmarino/alki.git
((ball || bhtml))  && ssync ~/wiki/wiki_html https://github.com/tinmarino/wiki_html
((ball || bhtml))  && ssync ~/wiki/alki_html https://gitlab.com/tinmarino/alki_html.git
# shellcheck disable=SC2154
((bvim))           && ssync "$v"             https://github.com/tinmarino/vimfiles


cout="$cbad"
if ((ok == n)); then
  cout="$cgood"
fi
echo "$s_error_msg"
echo -e "${cend}<--- Synchronization finished with: ${cout}$ok/$n\e[0m"

# vim:sw=2:ts=2:
