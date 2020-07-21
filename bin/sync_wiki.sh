#!/bin/bash
# This file serves for synchronosation

s_error_msg=''

# Sychrnonize argument folder
function ssync(){
    # Set vars
    title=$(basename -- "$1")
    title=${title^^}
    let ret=0

    # Log && Pushd
    echo "--->  $title  ================================================="
    mkdir $1 2> /dev/null && echo "[*] Created directory $1"
    pushd $1 > /dev/null

    # Create git repo
    if ! [ -d .git ]; then
        git clone $2 . && echo '[*] Initialised clone'
    fi

    # Git sync
    git add .
    message="___ <- sync_wiki.sh: Modified: $(git diff --name-only --cached | sed ':a;N;$!ba;s/\n/, /g')"
    git commit -m "$message"
    git pull --rebase
    if git push --all ; then
        echo '[+] push OK'
    else
        echo '[-] push failed'
        s_error_msg+="<- Failed: $1\n" 
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
let n++ ; ssync ~/wiki/wiki      https://github.com/tinmarino/wiki           && let ok++
let n++ ; ssync ~/wiki/wiki_html https://github.com/tinmarino/wiki_html      && let ok++
let n++ ; ssync ~/wiki/alki      https://gitlab.com/tinmarino/alki.git       && let ok++
let n++ ; ssync ~/wiki/alki_html https://gitlab.com/tinmarino/alki_html.git  && let ok++
let n++ ; ssync ~/wiki/todo      https://gitlab.com/tinmarino/todo.git       && let ok++
# let n++ ; ssync ~/wiki/html      && let ok++


echo $s_error_msg
echo "<--- Synchronization finihed with $ok/$n success"
