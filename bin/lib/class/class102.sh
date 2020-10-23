#!/usr/bin/env bash
# -- Tarea: Zoo de langauges
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+===================+
| Language: Python  |
+===================+$cend

Lo mejor es aprender manos arriba.
Por eso vamos a jugar en el sitio: https://www.hackerrank.com

${cblue}P00: Crear cuenta$cend
  Crea una cuenta al sitio de desafio de programadores: https://www.hackerrank.com

+===================+
| Language: Python  |
+===================+$cend

${cblue}P01: Python: Hello World$cend
  Imprime \"Hello world\" en la salida estandard:
  https://www.hackerrank.com/challenges/py-hello-world/problem


${cblue}End:$cend

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
