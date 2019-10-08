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

let err=0
let n=0

let n++ ;    ssync ~/.vim           || let err++
let n++ ;    ssync ~/wiki/wiki      || let err++
let n++ &&    ssync ~/wiki/wiki_html || let err++
let n++ &&    ssync ~/wiki/todo      || let err++
let n++ &&    ssync ~/wiki/html      || let err++


echo "<--- Synchronization finihed with $err/$n failed"
