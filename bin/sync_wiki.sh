#!/bin/bash
# This file serves for synchronosation

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# Sychrnonize argument folder
function ssync(){
    title=$(basename -- "$1")
    title=${title^^}
    let ret=0
    echo "--->  $title  ================================================="
    mkdir $1 2> /dev/null && echo "Created directory $1"
    pushd $1 > /dev/null
    git add .
    git commit -m "___ <- sync_git.sh"
    git pull --rebase
    if git push ; then
      echo '[+] push OK'
    else
      echo '[-] push failed'
      let ret=1
    fi
    popd > /dev/null
    echo "ret is $ret"
    return $ret
}

echo "---> Synchronizing from internet"

let ok=0
let n=0

let n++ ; ssync ~/.vim           && let ok++
let n++ ; ssync ~/wiki/wiki      && let ok++
let n++ ; ssync ~/wiki/wiki_html && let ok++
let n++ ; ssync ~/wiki/todo      && let ok++
let n++ ; ssync ~/wiki/html      && let ok++


echo "<--- Synchronization finihed with $ok/$n success"
