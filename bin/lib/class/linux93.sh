#!/usr/bin/env bash
# -- ${cblue}Examen$cend: fin de cyclo
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../shellutil.sh"

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
    Asemblado
    ByteCode
    MicroCode
    VHDL
    "
  [P09: Que hace el comando \"chroot\"?]="\
    Ejecuta un comando en un entorno con cambio de raiz.
    Un entorno donde no se puede acceder al sistema de archivos afuera del directorio que ha sido elejido como raiz.
    "
  [P10: Programacion: Que estipula el teorema de retorno (de Turing)]="\
    Que de forma generica no se puede predecir si un progrma retorna o no.
    Y entonces, de forma as generic, no se puede saber que rama va a seguir y lo que va a hacer.
    "
  [P11: Programacion: Porque la machina de turing se llama \"machina universal\"]="\
    Porque con cualquier machina de Turing se puede hacer toda las operaciones de otra.
    Eso esta llamado el Teorema de Turing. Desarollo todo eso solo para llegar al
    teorema del retorno que hoy dia es menos famoso que el desarollo.
    "
  [P12: Cuentame una diferencia entre Docker y Chroot]="\
    - Docker es mas moderno
    - Docker aisla mas cosas que el sistema de archivo (los espacios de nombre: PID< UID, GID, Hostname, IPC)
    - Docker tiene una CLI mucho mas potente: Puede manejar el ciclo de vida de los contenedores
    - En Docker, los contenedores se definen por capa, imagen y contenedor lo que ahora el disco duro.
    - En Docker, se pueden compartir imagenes en internet
    - Concluscion, Docker es Chroot++ como C++ es C .... ++!
    "
  [P13: Si big_file.txt tiene 2G lineas (2 miliares de lineas) de 80 characteres, este commando termina en mas o menos rapido que 1 segundo: \"cat big_file.txt | head\"? Porque ?]="\
    Termina en menos de 1 segundo, menos de 1ms porque el commando head manda la senal BROKEN_PIPE despues de leer la cabeza, las 10 primeras lineas.
    "
  [P14: Que es el Kernel Linux?]="\
    Ver la repuesta en las preguntas anteriores.
    "
  [P15: Que hace el simbolo \"|\" en una linea de comando BaSh? En una Regex?]="\
    En BaSh: Es un tubo: redirige el StdOut del comando a la izquierda en el StdIn del comando a la derecha.
    En RegEx: Es una Alternación: hace que la exprecion coincide si coincide la sub-exprecion de izquierda o la de derecha. Es un logico \"o\".
    "
  [P16: De que sirve un socket?]="\
    Para comunicar entre diferencentes procesos. Es un convencion de tubos multi-protocolos multi-machinas.
    "
  [P17: Que significa el acronymo HTTP?]="\
    HyperText Transfer Protoco
    "
  [P18: Cual es la diferencia entre un cliente y un servidor?]="\
    El cliente manda ordenes cuando el usario lo pide
    El servidor se queda escuchando (en general sobre un puerto), esperando ordenes y trabaja cuando recibe una orden.
    "
  [P19: Usando grep, muestra las lineas de /etc/passwd que terminan con \"sync\"]="\
    grep 'sync$' /etc/passwd
    "
  [P20: Que provee el servicio Apache?]="\
    Un Common Gateway Interface y de forma mas generica un serivico web.
    En general Http o Https.
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
    :
    # TODO at final
    # echo -e "$i"
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
