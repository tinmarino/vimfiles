#!/usr/bin/env bash
# -- Tarea: dd, filefrag, fork, exec
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+====================+
|  Explore: Homework |
+====================+$cend



${cblue}End:$cend

TODO 5
* Play with urandom and $RANDOM and command interpolation
* Null
* Hacer arvhicos muy grandes

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
