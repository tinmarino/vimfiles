
#!/usr/bin/env bash
# ${cblue}Clase 010$cend: De donde vengo, donde estoy, a donde voy
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  msg="$cblue
================+
|  File System  |
================+$cend

${cblue}P01: Donde estoy (PWD)?$cend
  ${cyellow}> pwd$cend
  'Present Working directory': te dice en que directorio estas, los commandos se ejecutaran en este directorio

${cblue}P02: Donde voy (CD)?$cend
  ${cyellow}> cd Class$cend
  'Change directory': te mueve a un otro directorio (como un doble click en una carpeta). Aqui el directorio Class no existe, entonces te da un error.
  Nota que ${cyellow}cd$cend sin argumento te mueve a tu casa (donde estas ahora)

${cblue}P03: Crear directorios (MKDIR)?$cend
  ${cyellow}> mkdir Class$cend
  'MaKe DIRectory': Crea una carpeta llamada Class en la carpeta donde estas ahora.
  More, para crear directorios imbricados, puedes usar la opcion ${cyellow}-p$cend. Como en {cyellow}mkdir Class/Dir1/Dir2/Dir3$cend

${cblue}P04: Listear los archivos de un directorio (LS)?$cend

  Ahora si puedes ir en la carpeta Test
  ${cyellow}> cd Test$cend
  ${cyellow}> pwd$cend
  Estas bien en $HOME/Test?

  Vamos a crear distintos archivos (confia en mi)
  ${cyellow}> for i in {1..10}; do touch file_\$i; done$cend
  ${cyellow}> mkdir Dir1$cend
  ${cyellow}> for i in {1..10}; do touch Dir1/file_in_dir_\$i; done$cend

  Y Miramos lo que hay en la carpeta del pwd
  ${cyellow}> ls$cend

${cblue}The end$cend
  Muy bien, la clase de hoy estaba sobre:
  ${cyellow}pwd, cd, mkdir, ls$cend
  Maniana vamos a ver:
  ${cyellow}mv, rm, history$cend
  "
  
  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
