#!/usr/bin/env bash
# -- ${cblue}Examen$cend: fin de cyclo
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

# TODO 35 questions
declare -A question=(
  [P01: Que es un daemon?]="\
    Los daemons son servicios que proporcionan varias funciones que pueden no estar disponibles en el sistema operativo base.
    Su tarea principal es escuchar la solicitud de servicio y, al mismo tiempo, actuar sobre estas solicitudes.
    Una vez realizado el servicio, se desconecta y espera más solicitudes.
    "
  [P02: Cuáles son los diferentes modos al usar el editor vi?]="\
    Hay 3 modos en vi: - Modo de comando: este es el modo en el que se inicia en el modo Editar: este es el modo que le permite editar texto - Modo Ex: este es el modo en el que interactúa con vi con instrucciones para procesar un archivo

    "
  [P03: ]="\
    "
  [P04: ]="\
    "
  [P05: ]="\
    "
  [P06: ]="\
    "
  [P07: ]="\
    "
  [P08: ]="\
    "
  [P09: ]="\
    "
  [P10: ]="\
    "
  [P11: ]="\
    "
  [P12: ]="\
    "
  [P13: ]="\
    "
  [P14: ]="\
    "
  [P15: ]="\
    "
  [P16: ]="\
    "
  [P17: ]="\
    "
  [P18: ]="\
    "
  [P19: ]="\
    "
  [P20: ]="\
    "
  [P21: ]="\
    "
  [P22: ]="\
    "
  [P23: ]="\
    "
  [P24: ]="\
    "
  [P25: ]="\
    "
  [P26: ]="\
    "
  [P27: ]="\
    "
  [P28: ]="\
    "
  [P29: ]="\
    "
  [P30: ]="\
    "
  [P31: ]="\
    "
  [P32: ]="\
    "
  [P33: ]="\
    "
  [P34: ]="\
    "
  [P35: ]="\
    "
)

__usage(){
  local msg="$cblue
+============+
| Examen 1/2 |
+============+$cend
  "
  echo -e "$msg"

  # shellcheck disable=SC2207  # Prefer mapfile
  IFS=$'\n' sorted_fct=($(sort <<<"${!question[*]}"))
  # shellcheck disable=SC2068  # Double quote
  for i in ${sorted_fct[@]}
  do
    echo -e "$i"
  done

  msg="${cblue}End:$cend
  "
  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
${cblue}End:$cend
  Flicitacion, se acabaste esta clase de Linux

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
