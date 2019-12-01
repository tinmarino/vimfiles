#!/bin/bash
# This file serves for synchronosation


# Sychrnonize argument folder
function ssync(){
    # Set vars
    title=$(basename -- "$1")
    title=${title^^}
    let ret=0

    # Log && Pushd
    echo "--->  $title  ================================================="
    mkdir $1 2> /dev/null && echo "Created directory $1"
    pushd $1 > /dev/null

    # Git sync
    git add .
    message="___ <- sync_wiki.sh: Modified: $(git diff --name-only --cached | sed ':a;N;$!ba;s/\n/, /g')"
    git commit -m "$message"
    git pull --rebase
    if git push ; then
      echo '[+] push OK'
    else
      echo '[-] push failed'
      let ret=1
    fi

    # Popd && Ret
    popd > /dev/null
    return $ret
}


echo "---> Synchronizing from internet"

let ok=0
let n=0

# let n++ ; ssync ~/.vim           && let ok++
let n++ ; ssync ~/wiki/wiki      && let ok++
let n++ ; ssync ~/wiki/wiki_html && let ok++
let n++ ; ssync ~/wiki/todo      && let ok++
# let n++ ; ssync ~/wiki/html      && let ok++


echo "<--- Synchronization finihed with $ok/$n success"
