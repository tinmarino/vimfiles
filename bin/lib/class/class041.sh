#!/usr/bin/env bash
# ${cblue}Syntax: Subshell$cend: Jobs, Signal, Command expansion
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+=================+
|  SubShell: Jobs |
+=================+$cend
$cblue
+======================+
| Parte 1: Expanciones |
+======================+$cend
  Antes de ejecutar cualquier linea, BaSh hace unas expanciones.
  Puedes leer (mucho) mas sobre eso en ${cyellow}man bash$end seccion \"EXPANSION\".

${cblue}P01: Expancion de casa: ~$cend
  Ya hemos visto como la tilde \"~\" se expande:
  ${cyellow}> echo ~$cend
  ${cyellow}> echo ~jim2$cend
  Si! Como el camino a tu casa, 1 character, para que sea facil encontrar tu casa!

${cblue}P02: Expancion de camino: *$cend
  ${cyellow}> echo *$cend  # Muestra todo los caminos
  ${cyellow}> echo *.txt$cend  # Muestra todo los caminos acabando en \".txt\"
  ${cyellow}> echo file*$cend  # Muestra todo los caminos empezando con \"file\"
  ${cyellow}> echo /usr/*/share$cend  # Muestra todo los caminso empezando en \"/usr\" con \"/share\"
  Est symbolo \"*\" Se llama el glob porque engloba \"cualquier wea tipo \"file*\" significa file seguido por \"cualquier wea\".
  Este tipo de especificacion de nombre (aqui de camino) es una exprecion regular. Y es muy potente!

${cblue}P03: Expancion de llave, como el \"o\": {}$cend
  No es muy muy util, solo achica un poco los commandos
  ${cyellow}> echo estoy-{feliz,triste,boracho}$cend
  ${cyellow}> echo {estoy,soy}-{feliz,triste,boracho}$cend
  Es como el \"o\" estoy feliz o triste o contento. Puede multiplicr rapidamente los argumentos.

${cblue}P04: Expancion arithmetica: \$(())$cend
  ${cyellow}> echo \$((2 + 2))$cend

${cblue}P05: Expancion de variable: \$$cend
  ${cyellow}> echo \$USER$cend
  ${cyellow}> toto=\"adentro\"; echo \$toto$cend

${cblue}P06: Substitucion de commando: \$()$cend
  Esa es muy util!
  Remplaza el \$(commando argumento) con el StdOut del command corrido
  ${cyellow}> echo \$(ls)$cend
  ${cyellow}> echo \"\$(ls)\"$cend
  ${cyellow}> ls -l \$(which cp)$cend
  ${cyellow}> file \$(ls /usr/bin/* | grep bin/zip)$cend

  Nota que todo las interpolaciones con \$ se ejecutan en \"\" pero no en ''

  ${cblue}SubShell:$cend Cuando ejecutas un commando en una substitucion de commando, la ejecutas en un subshell.
  Es importante entender lo que se puede pasar de un shell a otro (en tarea)
  ${cyellow}echo \$BASH_SUBSHELL$cend
  ${cyellow}echo \$(echo \$BASH_SUBSHELL)$cend
  ${cyellow}echo \$(echo \$(echo \$BASH_SUBSHELL))$cend


$cblue
+=============================+
| Parte 2: Senales y Trabajos |
+=============================+$cend

Las senales es la version la mas primitiva (en 1970) de las communicaciones entre processos.
Desde ya, han sido muy, muy criticados. Pero no solo existen, tambien Windows los ha implementado. Porque?
Porque, en 50 anios, en realidad, nadie logra hacer mejor.
Nota que la version mas desarollada de communicacion entre procesos son los \"sockets\" y funcionan con IP (Internet Protocol). lo que corresponde en linux en escribir en un archivo. Tambien existen los tubos, tubos con nombre, la memoria compartida (tambien escriir y leer \"archivos\")
Mas informaciones en ${cyellow}man 7 signal$cend.

Los trabajos son todo los procesos que ha ejecutado un shell, cada linea si corre un commando o un tubo (pipeline) es un trabajo.

${cblue}P10: Trabajos de fondo$cend
  Necesitamos un function de trabajo. Llamemosla \"work\".
  Ejecuta esta declaracion en tu shell:
  ${cyellow}> work(){ while true; do echo $1 is working; sleep 0.5; done; }$cend

${cblue}P11: Segnales: Ctrl-z, Ctrl-c$cend
  ${cyellow}> work Jim1$cend
  Apreta Ctrl-z
  Mandaste al ultimo trabajo (work Jim1) la senal: 19 - SIGSTOP - Pause the process / free command line, ctrl-Z (1st)
  ${cyellow}> work Jim2$cend
  Apreta Ctrl-c
  Mandaste al utltimo trabajo (work Jim2) la senal: 2 - SIGINT - interupt process stream, ctrl-C 

${cblue}P12: Senales: Fondo (bg)$cend
  ${cyellow}> work Jim3 &$cend  # Nota que \"&\" corre directamente el trabajo en background, es lo mismo que lo siguiente
  ${cyellow}> work Jim4$cend  # Press Ctrl-z
  ${cyellow}> bg$cend  # Press Ctrl-z

${cblue}P13: Segnales: Primer plano (fg)$cend
  ${cyellow}> work Jim5 &$cend
  ${cyellow}> fg$cend

${cblue}P14: Jobs and kill$cend
  Hay 2 seniales utiles:
    15 - SIGTERM - terminate whenever/soft kill, typically sends SIGHUP as well? 
    9 - SIGKILL - terminate immediately/hard kill, use when 15 doesn't work or when something disasterous might happen if process is allowed to cont., kill -9 

  Listea los senales:
  ${cyellow}> trap -l$cend

  Ahora a matar los trabajos
  ${cyellow}> jobs$cend  # Listea los trabajos
  ${cyellow}> kill -15 %2$cend  # Manda la senial 15 (TERMINATE) al trabajo numero 2
  Ahora TERMINA o MATA todo tus trabajos

${cblue}P15: Otro Shell$cend
  ${cyellow}> bash$cend  # Te hace entrar en un otro shell
  ${cyellow}> exit$cend  # Te hace salir de ese
  Que pasa de un shell a otro?
  Hablar de herencia

${cblue}End:$cend
  Acabaste la clase 4. Felicitacion!

  Has aprendido: Las expanciones de Bash con ~, *, {}, \$, \$(()), \$()
  
  Manana veremos: Los processos y los dispositivos

  De nuevo, buen trabajo,
  Buenas noches.
  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
