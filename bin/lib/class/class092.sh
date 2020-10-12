#!/usr/bin/env bash
# -- Tarea: wget, cron, cgi, jenkins
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+=================+
| Servicio: Tarea |
+=================+$cend

Hoy vamos a servir!


${cblue}P01: Clonar un sitio$cend
  TODO find a small website!
  TODO can I cone my github.io?


${cblue}End:$cend

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
