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
  [P03: Cual es la diferencia entre un interpretador y una maquina virtual]="\
      El interpretador: lee y ejecuta el codigo tal como lo escribio el programador. Ex: BaSh, Python, JavaScript
      La maquina virtual: lee y ejecuta codigo compilado o pseudo compilado. Ex: VirtualBox, Java Virtual Machine
      Ambos permiten abstraerse de la architectura de la maquina sobre la cual el codigo esta corriendo.
      Nota que un codigo pseudo compilado de una maquina virtual puede llegar a compilarse y correr en la arquitectura real para ser mas rapido. Ver \"Compilacion justo a tiempo\" de la Dalvik virtual machine de Java
      Tambien el interpretador puede elejir (pseudo) compilar lo que interpreta para ejecutarlo mas rapido. Ver Python pyc o JavaScript WebAssembly.
    "
  [P04: RegEx: Usando grep, imprime las lineas que empiezan con "root" en /etc/passwd]="\
    grep '^root' /etc/passwd
    "
  [P05: Bash: un cyclo donde la variable \"i\" toma los valores de 1 a 10 (inclusivo), imprime el contenido de \"i\" a cada vuelta]="\
    for i in {1..10}; do echo $i; done
    "
  [P06: Lenguaje: Dame un ejemplo de idioma compilado]="\
    C, Fortran, Rust
    "
  [P07: Lenguaje: Dame un ejemplo de idioma no compilado. A que nivel (tipo de salida) pertenece este idioma]="\
    Python es Interpretado
    "
  [P08: Lenguaje: Hay niveles de lenguaje mas bajo que el compilado? Si es que si da el ejemplo de un nivel (dije el nivel, no el lenguaje)]="\
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
    # TODO at final
    # if [[ "$1" == "long" ]] ; then
    #   echo "${question[$i]}"
    # fi
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
