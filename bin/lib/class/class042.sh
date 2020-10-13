#!/usr/bin/env bash
# -- Tarea: man, apropos, pstree, /dev/random
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+===============+
|  Jobs: Tareas |
+===============+$cend

Hay pocos ejercicios pero son largo => piano piano lontano


${cblue}P01: Listea y describe los commandos cononcidos$cend
  Me preguntaste: \"Hay un sitio para listas de commandos ?\"
  Y te respondi: \"Mejor vealo en TU sistema y mantenga tus notas tu mismo.\"

  Para resumir los commandos de esta clase, corre este commando:
  ${cyellow}> jim --doc | grep -o '> \\(sudo \\)\\?\\w\\+' | sed 's/sudo //' | cut -c 3- | sort -u | awk '{print \"apropos -l \\\"^\" \$1 \"\$\\\"\"}' | bash 2>&1 | grep -v \"nothing appropriate\"$cend
  Puedes redirecionar el output de este en un archivo para leerlo mas tranquilo

  --> Aparte
  A ver lo que hace <= es un interesante ejemplo real.
  No copies estos commandos, es solo una descripcion:
  ${cyellow}> jim --doc$cend  # Ese es un commando que el yo hice, que escribe todo el el StdOut
  ${cyellow}> grep -o '> \\(sudo \\)\\?\\w\\+'$cend  # Agara: -o = escribe solo lo que agaro y lo las lineas enteras como el defecto, un character \">\", despues \"sudo \" o no \"\\?\", despues characters de palabra \"\\w\", 1 o mas \"\\+\", ese ultimo argumento es una ${cblue}Exprecion Regular$cend
  ${cyellow}> sed 's/sudo //'$cend  # Remplaza \"sudo \" (sudo y espacio) por nada (en cada linea)
  ${cyellow}> cut -c 3-$cend  # Corta (Cut) los 3 (\"3\") primeros caracteres (\"c\")
  ${cyellow}> sort -u$cend  # Ordena lexicographicamente de forma unica: lo mismo que ${cyellow}sort | uniq$cend pero mas rapido (porque corre un processo y no dos)
  ${cyellow}> awk '{print \"apropos -l \\\"^\" \$1 \"\$\\\"\"}'$cend  # Reordona un poco la impression, poniendo apropos antes que es un commando como man: ver (${cyellow}> apropos hostname$cend)
  ${cyellow}> bash 2>&1$cend  # Pipe to BaSh para ejecutar ${cyellow}apropos$end. Y redireciona la Salida 2 (StdErr) a la 1 (StdOut) porque apropos, aparetemente escribe en el StdErr pero los tubos solo redirectionan el StdOut
  ${cyellow}> grep -v \"nothing appropriate\"$cend  # Agara todas las lineas excepto las que contienen \"nothing appropriate\", porque son lineas donde apropos no encontro nada, porque no eran commandos sino nombre de archivos
  <-- Fin del aparte

  Elegante? O super feo?
  Ambos! Pero ha sido facil de escribir (paso a paso), y hace automagicamente las tareas de extracion y reporte.


${cblue}P02: Los subshells crean otro procesos$cend
  Escribe un programa que genera un subshell que trabaja
  ${cyellow}> echo '(while true; do echo \"Subshell running . . .\"; sleep 0.3; done; )' > subshell.sh$cend
  Ejecutalo (Mejor dicho interpretalo con Bash) en fondo, pero redireciona su StdOut al agujero negro (sino te llena la pantalla y es molestoso).
  ${cyellow}> bash subshell.sh > /dev/null &$cend
  Observa que se genero dos processos.
  ${cyellow}> ps -aux | grep subshell.sh$cend
  El proceso creo un hijo al entrar en un subshell

  Y si entras en un subshell desde un subshell (imbricacion):
  ${cyellow}> echo '( :; (while true; do echo \"Subshell running . . .\"; sleep 0.3; done; ) )' > subshell2.sh$cend
  ${cyellow}> bash subshell2.sh > /dev/null &$cend
  ${cyellow}> ps -aux | grep subshell2.sh$cend
  Ahora son 3 processos

  Con el primer trabajo todavia corriendo en fondo, son 5 processos
  ${cyellow}> ps -aux | grep subshell$cend

  Matalos:
  ${cyellow}> jobs$cend  # Deberias ver 2 trabajos ya que corriste 2 commandos
  ${cyellow}kill %1 %2$cend

  Y no queda ningun processo: Al terminarse, los processos padres mandaron una senal a sus hijos que se acabaron
  ${cyellow}> ps -aux | grep subshell$cend


${cblue}P03: Los subshells clonan toda las variables$cend
  > var=41
  > echo OUTSIDE subshell \$var
  > ( ((var++)); echo \"INSIDE subshell = \$var\" )   # Nota la interpolacion arithmetica con (()). No cunfundir con el subshell con simple ()
  > echo OUTSIDE subshell \$var

  Pero las variables del subshell no se transiten a su padre.

  Nota que este fenomeno se puede usar como ventaja para tener \"variables locales\".
  Mas sobre eso en la clase 10: idiomas de programacion.
  Por mientras retiene que todas la varibles que se crean, modifican o destuyen en un subshell, no cambian en su padre porque en realidad no son la mismas variables sino clones.
  Este fenomeno de clonaje es esclusivo al shell, y se demora un poco. Los otros idioma no clonean implicitamente sino que mantienen explicito lo que llaman en enfoque (scope) de una variable y afuera del enfoque, ni se puede ver la variable. Pero eso es otra clase.


${cblue}P04: Variables \$\$ y \$BASHPID en los subshell$cend
  ${cyellow}> clear$cend

  ${cyellow}> echo \"\\\$\\\$ outside of subshell = \$\$\"
echo \"\\\$BASH_SUBSHELL  outside of subshell = \$BASH_SUBSHELL\"
echo \"\\\$BASHPID outside of subshell = \$BASHPID\"$cend

  Nota que los {} grupan los commandos pero no crean un subshell: mientras que ejecutar 3 lineas de commandos, es ejecuta una linea de 3 commandos.
  ${cyellow}> { echo \"\\\$\\\$ outside of subshell = \$\$\"
echo \"\\\$BASH_SUBSHELL  outside of subshell = \$BASH_SUBSHELL\"
echo \"\\\$BASHPID outside of subshell = \$BASHPID\"; }$cend

  Ahora si entramos en un subshell?
  ${cyellow}> ( echo \"\\\$\\\$ inside of subshell = \$\$\"
echo \"\\\$BASH_SUBSHELL inside of subshell = \$BASH_SUBSHELL\"
echo \"\\\$BASHPID inside of subshell = \$BASHPID\" )$cend

  Que variable cambio y como? Anotalo bien, quizas saldra en la prueba!

  Ahora que entiendes los {}, los vamos a ocupar para grupar commandos sin escribirlas todas en la misma linea con \";\" o \"&\" => sera mas facil leerlas pero es lo mismo.


${cblue}P05: Subshell y asynchronysmo$cend
  ${cyellow}> jobs$cend  # Asegurate que no tienes trabajos en fondo antes de seguir. Si hay, matalos con (> kill %12) donde 12 es el numero del trabajo
  ${cyellow}> (sleep 1) & (sleep 2) & (sleep 3) & wait$cend

  El commando (> wait) espera que todo los jobs sean terminados antes de terminar. Asi

  Que se puede escribir
  ${cyellow}> { (sleep 1) &
(sleep 2) &
(sleep 3) &
wait }$cend

  Viste que es mas facil leer!


${cblue}P06: Senal, atrapar Ctrl-C (trap)$cend
  ${cyellow}> trap -l$cend  # Recordatorio (no tienes que aprenderlos)
  ${cyellow}> trap 'echo \"Ctrl-C pressed\"' 2$cend  # Define el manipulador (handler) de la senal 2 (SIGINT).

  Presiona Ctrl-C distintas veces para ver lo que pasa

  Nota que puedes remplazer \"2\" por \"INT\" o \"SIGINT\" el nombre de la senal
  Nota tambien que puedes atrpar todos los sinales en la lista exepto el mas famoso, el 9 el de la muerte. Como se llama? (ver > trap -l). Este es imparable y mata si o si un proceso, si condiciones ni bifurcaciones.

  ${cyellow}> trap - 2$cend  # Remueve el manipulador del 2 => SIGINT vuelve a su funcion original

  Presiona Ctrl-C


${cblue}P07: Trap salida de un programa (EXIT)$cend
  Puede ser convniente ejecutra codigo a la salida de un programa.
  Aqui, para no escribir un archivo, vamos a usar un SubShell como programa. Ahora que sabes que son, en realidad otros programas
  ${cyellow}> ( trap \"echo 'Runned at exit'\" EXIT; echo 'Before exit'; exit; echo 'After exit'; )$cend

  Correlo, y sigue lo que pasa. Por supuesto el 'After exit' nunca esta llamado
  Nota que EXIT no es un senal, es una funcionalidad mas de \"trap\"


${cblue}P08: Trap cada linea (DEBUG)$cend
  ${cyellow}> var=11$cend
  ${cyellow}> trap 'echo var = $var' DEBUG$cend  # Nota que las citas son doble, asi el \$ no se interpola (todavia). Que psas si las pongo doble
  ${cyellow}var=22$cend
  ${cyellow}echo 'Cualquier wea'$cend
  ${cyellow}> ((var*=2))$cend  # Bobla el valor de var gracias al contexto arithmetico
  ${cyellow}trap - DEBUG$cend  # Para la wea

  Nota que DEBUG tampoco es un senal, es una funcionalidad mas de \"trap\"


${cblue}P09: Matar no necesariamente mata$cend
  Sino que manda una senal, si esa senal es la 9, eso si que mata!
  ${cyellow}> kill $(jobs -p)$cend   # Kill all jobs, nota la substitucion de commando

  Atrapame
  > trap \"echo Process \$BASHPID received SIGUSR1\" SIGUSR1
  > trap \"echo Process \$BASHPID received SIGUSR2\" SIGUSR2

  Mandame una senal a mi mismo (se usa mucho)
  ${cyellow}> kill -s SIGUSR1 \$\$$cend
  ${cyellow}> kill -10 \$\$$cend  # Lo mismo
  ${cyellow}> kill -s SIGUSR2 \$\$$cend

  Ahora en un subshell:
  ${cyellow}> (
# Dice hola
echo spawning \$BASHPID and sleeping forever;
# Instala un manipulador
trap \"echo Process \$BASHPID received SIGUSR1\" SIGUSR1;
# Duerme, despierta duerme
while true; do sleep 0.1; done
# Corre el subshell en fondo
) &$cend

  Verifica
  ${cyellow}> jobs$cend  # Debria haber un job [1]

  Manda la senal SIGUSR1 (10) al primer job => el subshell
  ${cyellow}> kill -s SIGUSR1 %1$cend
  ${cyellow}> kill -10 %1$cend

  # Ahora terminalo sin condiciones
  ${cyellow}kill -9 %1$cend

  Verifica
  ${cyellow}> jobs$cend  # No deberia haber ningun job


${cblue}End:$cend
  Acuerdate:
    - ${cblue}kill$cend no sirve solo para matar sin condiciones, pero para mandar senales que se atrapan con ${cblue}trap$cend, o tienen un manipulador por defecto descrito en el manual.
    - un ${cblue}subshell${cend} es un otro proceso que clona todo del shell y desaparace con su estado

  Veremos justamente como se hace este clonaje y que es tipico de la formacion de proceso en Linux (no en Windows)

  Felicitacion por haber hecho tu tarea en casa y leido hasta el final.
  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
