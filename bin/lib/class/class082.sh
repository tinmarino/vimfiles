#!/usr/bin/env bash
# -- Tarea: Script bash
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+=================+
|  TODO: Homework |
+=================+$cend
${cblue}End:$cend


TODO:
  pequeniso programas que se pueden leer o poner en tubos para compilar y ejecutar: Sin color si en tubo
  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
