#!/usr/bin/env bash
# ${cblue}System: Heramientas$cend: git, vim
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+==============+
| Parte 1: Git |
+==============+$cend

$cblue
+==============+
| Parte 2: Vim |
+==============+$cend
  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
