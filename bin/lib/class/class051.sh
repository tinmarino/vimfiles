#!/usr/bin/env bash
# ${cblue}System: Explore$cend: Process, Device: pstree, /dev/zero
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+==========================+
| Parte 1 Explore: Process |
+==========================+$cend

$cblue
+==========================+
| Parte 2 Explore: Process |
+==========================+$cend
${cblue}End:$cend

  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
