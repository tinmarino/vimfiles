#!/usr/bin/env bash
# -- Tarea: wc, seq, sed, ask, bash
#
# shellcheck disable=SC2154  # cblue is referenced but not
# From: https://cvw.cac.cornell.edu/Linux/exercise
# Link: https://swcarpentry.github.io/shell-novice/04-pipefilter/index.html
# -- Buenisimo: Molecules

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+=========================+
|  Redirections: Homework |
+=========================+$cend


${cblue}P01: Guardar las clases en un texto$cend
  Habia que remover los colores
  ${cyellow}> sed 's/\\\x1b\\\[[0-9;]*m//g'$cend

  Hay una opcion en el commando jim que permite correr toda la doc de los escript que resulta ser las clases:
  ${cyellow}> jim --doc$cend

  La solucion es entonces
  ${cyellow}> jim --doc | sed 's/\\\x1b\\\[[0-9;]*m//g' > clases.txt$cend


${cblue}P02: Muestra todo los commandos en tu historia que tenian el commando \"sed\"$cend
  Puedes Agrarar (Grab en ingles -> Grep) las lineas que contienen \"sed\" con
  ${cyellow}> grep sed$cend

  Y ver tu historia con
  ${cyellow}> history$cend

  Lo demas es el tubo


${cblue}P03: Cuantos procesos BaSh coren en tu maquina (virtual)$cend
  Listeas los commandos que corren con
  ${cyellow}> ps -ef$cend
  Ps para ProcesS, E para Every y F para Full Format

  Agara solo los BaSh con
  ${cyellow}> grep bash$cend
  Pero mira que te vew a ti mismo, mira el ultimo processo no es un bash, es el mismo \"commando tubo\" (pipeline) que estas corriendo que se \"agaro\" (grep) a si mismo, que absurdo!

  Cuentas las lineas con
  ${cyellow}> wc -l$cend
  Word Count -Line

  Y finalmente, ya que estamos aqui, substraes uno con
  ${cyellow}> echo \$(( \$(cat -) - 1 ))$cend
  Que es el echo de la evaluacion arithmetica \$(()) del input estandar \$(cat -) menos uno.
  Nota que la expresion \$(cat -) es una interpolacion de commando que no hemos visto, pero que es muy facil, solo se interpola con el StdOut del commando adentro

  Lo total te da
  ${cyellow}> ps -ef | grep bash | wc -l | echo \$(( \$(cat -)-1 ))$cend
  Lo que es largo y no lo quieres escribir 2 veces.
    1. Lo puedes bucar en tu historia
    2. Lo puede poner en una function (y despues en un archivo como ese mismo que lees)

  ${cyellow}> count_bash(){ ps -ef | grep bash | wc -l | echo \"Hay \$(( \$(cat -)-1 )) procesos BaSh corriendo ahora\"; }$cend
  Para definir la funcion, y despues
  ${cyellow}> count_bash$cend
  Para usarla

  Lo lograste? BaKaN! Tu primera funcion en BaSh. Vez que el Shell es un idioma real, aunque sea debil para cosas (arithmetica, velocidad, seguridad ...) es el mejor del mundo para los tubos.
  Y corre en todas maquinas, tambien tu Window, tambien mi Android. Pero eso es para esta noche.


${cblue}P04: Cuantos Commandos unicos has corrido$cend
  Nota: utilisa los commandos:
  ${cyellow}> uniq$cend
  ${cyellow}> wc -l$cend


${cblue}P05: Cuantos numeros primos entre 1 y 1000$cend
  Regalo: Aqui te escribo una funcion que filtra los numeros primos usando el commando ${cblue}factor$cend (que quizas tienes que instalar

  ${cyellow}> is_prime(){ while read line; do factor \$line | grep -qE '^(.*): \\1\$' && echo \$line; done; }$cend
  Que se lee mejor asi (es la misma, tienes que copiarla solo 1 vez):
  ${cyellow}> is_prime(){
    while read line; do  # Para cada linea del StdIn
       factor \$line | grep -qE '^(.*): \\1\$' && echo \$line;  # Si el comando factor no tiene mas que un numero en salida, echo el numero
    done
  }$cend

  Para imprimir la sequencia de 1000 numeros, nada mas facil:
  ${cyellow}> seq 1000$cend

  Y como de costumbre, cuenta las lineas.

  Encontraste 168? Felicitacion!

${cblue}P06: Un caso Real: Pipe To BaSh$cend
  Muchos ejemplos de informatica son de arithmetica, aunque que quasi jamas se usa (es mas facil para el profe generar numeros que textos).
  Ahora vamos a ver un caso muy muy comun de los tubos, que llamos el tubo hacia BaSh
  Acuerdate de la funcion de la clase: Los 20 tags de informatica los mas de moda.

  Lo imbricamos en una funcion:
  ${cyellow}> echo_tag(){ jim class021 top_tag | grep -v '^ *#' | grep -v '^ *$' | sort -n -k 2 | head -n 20 ; }$cend

  Corre la funcion:
  ${cyellow}> echo_tag$cend

  Para cada linea, queremos crear un archivo, que tiene como prefijo su rango, como nombre, su tag y como contenido sus puntos. Por ejemplo el archivo \"1_javascript\" con contenido \"2097175\" y el archivo \"2_java\" con contenido \"1717945\".
  Vamos a hacer los comandos \"echo 2097175 > 1_javascript\" y \"echo 1717945 > 2_java\" y ...
  Pero no los vamos a copiar a mano! Vamos a generar estos comandos, imprimirlos en el StdOut y hacer un tubo hasta BaSh (en interpretador0 que entonces va a ejecutar estos commandos.

  Pequenia prueba:
  ${cyellow}> echo 'echo hola hablo demasiado > test_file.txt'$cend
  ${cyellow}> echo 'echo hola hablo demasiado > test_file.txt' | bash$cend
  ${cyellow}> cat test_file.txt$cend

  Grande prueba (en arenero es decir la terminal como StdOut, asi no rompes nada):
  ${cyellow}> echo_tag | awk '{print \"echo \" \$3 \" > \"  \$2 \"_\" \$1 \".txt\"}'$cend
  El comando awk, es expreto en cambiar columnas, aqui imprime en orden echo, la columna 3, el simbolo >, la columna 2 ... Como siempre, cuida los espacios

  Grande test:
  Copia pega la primera linea, ejecutala, ve si el archivo se creo, copia pega otra linea, se creo ? Entonces esta todo bien. Ahora si pudes dispara el mega commando que tendra efectos de bordos grandes (generar 20 archivos que es su objectivo)
  ${cyellow}> echo_tag | awk '{print \"echo \" \$3 \" > \"  \$2 \"_\" \$1 \".txt\"}' | bash$cend

  Todo bien! Ouf no rompimos nada (esta vez), mientras no usas el commando prohibido, y trabajas en un direcotrio de Test, uchas cosas deberian ser reversibles.

${cblue}End$cend
  Felicitacion, Los tubos (pipeline) deben mucho a los filtros.
  Esta noche vermos los usarios y las machinas (alias la red).
  Si quieres adelantarte: su -, who, w, whoami, ip or ifconfig, dig, traceroute, route
  Y el comando de los hacker: nmap si prepare bien la clase.
  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
