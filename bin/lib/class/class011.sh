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

${cblue}P03: Crear directorios (MKDIR)$cend
  ${cyellow}> mkdir Class$cend
  'MaKe DIRectory': Crea una carpeta llamada Class en la carpeta donde estas ahora.
  More, para crear directorios imbricados, puedes usar la opcion ${cyellow}-p$cend. Como en {cyellow}mkdir Class/Dir1/Dir2/Dir3$cend

${cblue}P04: Listear los archivos de un directorio (LS)$cend

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

${cblue}P05: Crear archivos (vacios) (Touch)$cend
  ${cyellow}> touch file_con_nombre_cualquiera.txt$cend
  'Touch' Toca un archivo, dandole vida (el soplo de dios)
  Ahora juega, quiero que tengas 20 archivos en la carpeta corriente

${cblue}P06: Remover (RM)$cend
  ${cyellow}> rm file_con_nombre_cualquiera.txt$cend
  'ReMove' Es un commando my peligroso, usalo con cuidado o mejor, no lo uses, mejor 'Mover a la basura' que remover, lo que nos lleva al ejercicio siguiente:

${cblue}P07: Mover (MV)$cend
  ${cyellow}> touch file_new.txt$cend  # Crea archivo
  ${cyellow}> mkdir ~/Trash$cend  # Crea basura en tu casa: ~ es un alias para tu casa
  ${cyellow}> mv file_new.txt ~/Trash/$cend  # Mueve el archivo a la basura
  'Move' mueve un archivo o una carpeta desde una carpeta a una otra

${cblue}P08: Historia (HISTORY)$cend
  ${cyellow}> history$cend
  'History' te muestra todo los commandos que hiciste haste ahora, las teclas arriba y abajo tambien te permiten navegarlas

${cblue}P09: Limpia pantalla (CLEAR)$cend
  ${cyellow}> clear$cend
  'Clear' permite limpiar tu terminal


${cblue}The end$cend
  Muy bien, la clase de hoy estaba sobre:
  ${cyellow}pwd, cd, mkdir, ls, mv, rm, history, clear$cend

  Maniana vamos a ver:
  ${cyellow}echo, cat, man, apropos, head, tail, less$cend

  ${cred}A retener:$cend son muchos pequenios commandos que ${cred}hacen solo una cosa pero la hacen bien$cend. Esta ultima assercion es ${cred}la filosofia de Linux$end
  "
  
  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
