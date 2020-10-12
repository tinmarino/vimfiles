#!/usr/bin/env bash
# -- ${cblue}Examen$cend: medio cyclo
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

# TODO 35 questions
declare -A question=(
  [P01: Describe lo que pasa cuando apretas Ctrl-Z mientras un commando se ejecuta.]="\
    "
  [P02: Como puedes ver el historico de los commandos que hiciste?]="\
    > history
    "
  [P03: Que significa SSH?]="\
    Secure SHell
    "
  [P04: Que es el kernel Linux?]="\
    El Kernel de Linux es un software de sistemas de bajo nivel cuya función principal es administrar los recursos de hardware para el usuario.
    También se utiliza para proporcionar una interfaz para la interacción a nivel de usuario.
    Esta interface se puede acceder mediante archivos (file) y llamada systema (system call o syscall).
    "
  [P05: Que es la cuenta root?]="\
    La cuenta raíz (root) es como una cuenta de administrador de sistemas y le permite un control total del sistema.
      Aquí puede crear y mantener cuentas de usuario, asignando diferentes permisos para cada cuenta.
      Es la cuenta predeterminada cada vez que instala Linux.
      Su numero de usario es 0. Se puede averiguar en /etc/passwd
    "
  [P06: Como se copia pega en la terminal? Porque no se puede usar Ctrl-C?]="\
    Se copia pega con selection y boton del medio (mediante el \"selection clipboard\").
    O con Ctrl-Shift-C y Ctrl-Shift-P.
    No se puede usar Ctrl-C porque desde 1970, sirve para mandar la segnal SIGINT (2) que interumpe el processo corriendo en primer plano (si es otro que el shell).
    "
  [P07: Como saber cuanta RAM libre tiene el systema?]="\
    > free -m
    "
  [P08: Como cambiar los permisos \(Read, Write, Execute\) de un archivo?]="\
    > chmod +x script.sh  # Para dar el derecho en escritura al dueno del archivo
    "
  [P09: Que son los archivos que empiezan con un punto?]="\
    En general, los nombres de archivo que están precedidos por un punto son archivos ocultos.
    Estos archivos pueden ser archivos de configuración que contienen datos importantes o información de configuración.
    Establecer estos archivos como ocultos hace que sea menos probable que se eliminen accidentalmente.
    "
  [P10: Que significa GUI y CLI? Que es la diferencia entre los 2?]="\
    GUI: Graphical User Interface
    CLI: Command Line Interface
    El GUI, se usa de forma graphica, se puede usar el raton, se puede incluir imagenes. Como Firefox.
    EL CLI, se usa con un prompt, con lneas de commando. Como Bash interactivo (el prompt, tambien llamado shell).
    "
  [P11: Que hace el commando pwd? Que significa?]="\
    Print Working Direcotory.
    Escribe el directorio actual de trabajo en la salida estandar.
    Como > echo \$PWD.
    "
  [P12: De que sirve el commando sudo?]="\
    Sirve para ejecutar los argumentos como un commando hecho por el usario root.
    "
  [P13: Como se llama el operador \"|\"? Que hace?]="\
    El operador \"|\" se llama \"tubo\" (en ingles \"pipe\").
    Redirection la salida estandar del commando que lo precede en la entrada estandar del commando que lo sigue.
    "
  [P14: De que sirve el commando \"grep\"?]="\
    Sirve para filtrar las lineas de su entrada estandar y selecionar solo las que contienen un patron especifico.
    Se especifica el patron como argumento del commando.
    Ex: > grep palabra_que_busco
        > grep -v palabra_no_quiero_ver  # v como inVert
    "
  [P15: Como se escriben commentario en una linea de commando Bash?]="\
    Los comentarios se crean escribiendo el símbolo # antes del texto del comentario real.
    Esto le dice al shell que ignore completamente lo que sigue.
    Por ejemplo, \"# Esto es solo un comentario que el shell ignorará\".
    "
  [P16: Como se ejecuta mas de un commando en una linea?]="\
    Se puede combinar varios comandos separando cada comando o programa con un símbolo de punto y coma (\";\").
    Por ejemplo, se puede emitir una serie de comandos de este tipo en una sola entrada:
    > ls –l; cd ..; ls –a MYWORK
    "
  [P17: Escriba un comando que busque archivos con una extensión \"c\" y que contenga la cadena \"apple\".]="\
    Hay distintas formas. La del profe es:
    > ls | grep '*.c' | grep 'apple'

    La del sitio era:
    > find ./ -name \"*.c\" | xargs grep –i \"apple\"
    "
  [P18: Escriba un comando que muestre todos los archivos .txt, incluido su permiso individual.]="\
    > ls -al *.txt  # a = All: muestra los archivos escondidos, l = List, muestra los permisos, la fecha de creacion, el dueno
    "
  [P19: Que esta mal en cada uno de los siguientes commandos: a/ \"ls -l-s\" b/ \"cat file1, file2\" c/ \"ls - s Factdir\"? Consejo: cada uno tiene algo mal.]="\
    a) debe haber espacio entre las 2 opciones: \"ls -l -s\" o nada \"ls -ls\"
    b) no use comas para separar argumentos: \"cat file1 file2\"
    c) no debe haber espacio entre el guión y la etiqueta de la opción: \"ls –s Factdir\"
    "
  [P20: Cuál es el comando para calcular el tamaño de una carpeta?]="\
    La repuesta es \"du\" como Disk Usage.
    Ex: > du –sh folder
    "
  [P21: Cómo se puede agregar un archivo a otro en Linux?]="\
    > cat file2 >> file1  # Agrega el contenido de file1 en file2
    o
    > cat file1 file2 > file3  # Concatena fil1 y file2 en file3, creando este ultimo.
    "
  [P22: Cómo se puede crear un direcotrio?]="\
    > mkdir folder  # Para crear el directorio con nombre folder
    "
  [P23: Escribe un commando que permite ver el contenido del archivo \"file.txt\".]="\
    > cat file.txt  # Para imprimir su contenido en la terminal (salida estandar si no hay tubos)
    o
    > xdg-open file.txt  # Para abirlo en el programa por defecto
    o
    > vi file.txt  # Para abrilo en el editor de texto \"vi\" que vermos despues
    "
  [P24: Suponemos que hemos escribido la funcion \"work\" que hace un tipo de trabajo demoroso. Cual es la differencia entre el commando \"work\" y el commando \"work &\" con una \"&\" al final?]="\
    Agregando una \"&\" al final corre el programa (o la funcion) en segundo plano, asi la entrada estandar de la terminal vuelve al usario.
    "
  [P25: Como puedes instalar un programar en lubuntu? Por ejemplo \"git\".]="\
    > sudo apt install git
    "
  [P26: Cual es el commando que permite acceder a la documentacion de un commando?]="\
    man como MANual
    "
  [P27: Escribe el commando para renombra el archivo \"file1\" en \"file2\"]="\
    mv file1 file2
    "
  [P28: Escribe el commando para remover el archivo \"file with spaces.txt\". Cuidado que el archivo tiene espacio en su nombre.]="\
    Hay que poner citas. Simple o doble da lo mismo porque no hay \$ en su nombre y no lo interpolamos
    > rm 'file with spaces.txt'
    Si se olvida loas citas, el commando \"rm\" va a remover los archivos \"file\", \"with\" y \"spaces.txt\" lo que no es el objectivo.
    "
  [P29: Como saber la version de tu kernel?]="\
    > uname -a  # Les pides al kernel: give me \"your name\" completo (-a = all)
    "
  [P30: A que corresponde el descriptor de archivo numero 0?]="\
    0: Entrada Estandar (StdIn)
    1: Salida Estandar (StdOut)
    2: Salida de \"Errores\" (StdErr)
    "
  [P31: Escribe un commando que escribe en mensage \"Message with spaces\" en la terminal.]="\
    > echo \"message with spaces\"  # Las citas pueden ser simple ya que no hay \$ ni interpolacion
    "
  [P32: Escribe un comando que crea el archivo file.txt con el contenido \"content\".]="\
    > echo content > file.txt
    "
  [P33: Escribe el commando que permite abrir un shell en la machina con IP 192.168.0.9 para el usario jim.]="\
    > ssh jim@192.168.0.9
    "
  [P34: Cual es la salida del commando \"echo \$\(\( 2 + 3 * 2 \)\)\"?]="\
    \"8\": \$\(\(\)) hace la interpolacion arithemtical de 2 + 3 * 2.
    La mutiplicacion tiene prioridad sobre la adicion (como saben los alumnos con papel y lapiz). 3 x 2 = 6. 6 + 2 = 8
    "
  [P35: Cual es la salida del commando \"var=42; echo \'\$var\'\"?]="\
    \"\$var\": Porque las citas simple no interplan las variable.
    La trampa era responder 42 como para  \"var=42; echo \"\$var\"\" (con citas doble)
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
    if [[ "$1" == "long" ]] ; then
      echo "${question[$i]}"
    fi
  done
}


get_fct_dic
call_fct_arg "$@"
