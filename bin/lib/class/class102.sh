#!/usr/bin/env bash
# -- Tarea: trap, docker, nmap, openssl
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+==================+
| Piedritas: Tarea |
+==================+$cend

${cblue}P01: Monitoreo (top)$cend
  ${cyellow}> top$cend
  En una terminal:
  [+] Es facil ejecutar, aun a distancia (ssh sin configuracion)
  [-] Es feo y (muy) complicado de usar (con el teclado)

  Tienes una applicacion llamada \"System Monitor\"?

${cblue}End:$cend

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
