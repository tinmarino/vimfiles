#!/usr/bin/env bash
# -- Examen de fin de cyclo
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+============+
| Examen 2/2 |
+============+$cend

${cblue}End:$cend
  Flicitacion, se acabaste esta clase de Linux

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
