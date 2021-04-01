#!/usr/bin/env bash
# ${cblue}System: Explorar$cend: Process, Device: pstree, /dev/zero
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../shellutil.sh"

__usage(){
  local msg="$cblue
+=============================+
| Parte 1 Explorar: Processos |
+=============================+$cend


${cblue}P01: Lista de processo (ps)$cend
  ${cyellow}> ps$cend  # Como ProcesseS da la lista de los procesos
  ${cyellow}> ps -aux$cend  # Suelo usar ese, puedes agragar -f para full
  ${cyellow}> ps -aux | grep bash$cend  # Y siempre se usa en un tubo


${cblue}P02: Arbol de processos (pstree)$cend
  ${cyellow}> pstree -alp$cend  # -a = muestra la linea de commando del commando, -l = formato largo, -p = muestra el PID

  Redirecionalo en un archivo y lee el archivo
  ${cyellow}> pstree -alp > process_tree.txt$cend
  ${cyellow}> xdg-open process_tree.txt$cend

  Encuentra tu propio processo: pstree y sus padres

  De forma mas sencilla:
  ${cyellow}> pstree -al -s \$\$$cend
  Muestra especificamente el proceso con PID \$\$ es decir el presente Shell

  ${cyellow}> man systemd$cend


${cblue}P03: Clonear un proceso (fork)$cend
  La forma que tiene Linux de crear procesos es clonear un proceso (padre). Uno de los clones queda siendo el mismo y el otro llega a ser el hijo. Este rpoceso se hace mediante la llamda systema ${cblue}fork$end.
  En el Shell, se llama un SubShell, lo que hemos visto en la clase precedente con la substituciones de commando.
  Un subshell se puede generar adentro de \"()\" y se genera automaticamente cuando el proceso se pone en fondo (con \"&\") sino no podrias acceder a tu \"prompt\"hasta que se termine y el proceso no estaria en fondo. Cierto?

  Este ejercicio es para entender el proceso de la herencia. El (proceso) hijo herede del (proceso) padre pero el padre no herede del hijo.

  ${cyellow}> var=42$cend  # En el padre
  ${cyellow}> echo In father shell: \$var$cend
  ${cyellow}> (echo in subshell 1: \$var; var=31; echo in subshell 2: \$var);$cend  # El hijo cambia var
  ${cyellow}> echo In father shell: \$var$cend  # Pero el padre todavia tiene su var original. Hubo un clonage de la variable var y de mucho mas cosas


${cblue}P04: Remplazar un proceso (exec)$cend
  Forkear esta bien, pero clonea el proceso, como hago si quiero correr un otro proceso, pro ejemplo ${cblue}cat$cend, ${cblue}wait$cend o ${cblue}vim$end?
  En este caso se usa el commando ${cblue}exec$cend que hace la llamada de systema del mismo nombre
  ${cyellow}> exec cat /dev/urandom$cend
  ${cyellow}> exec sleep 2$cend

  Como este proceso se vuelve el proceso padre del emulador de terminal, al acabarse, se ciera la terminal!


$cblue
+==========================+
| Parte 2 Explore: Device  |
+==========================+$cend

${cblue}P11: Arbol de archivos (tree)$cend
  Los mismos que pstree para imprimir el arbol de archivos.
  ${cyellow}> tree$cend
  Lo uso a veces para escribir documentation de un codigo


${cblue}P12: Zero a file (dd): descripcion de filefrag$cend
  ${cblue}dd$cend significa \"Disk Dump\". Es un commando como cat orientado a los bytes y no a los caracteres imprimibles. Es mas bajo nivel => mas dificil de usar pero tiene mas utilidades potencilaes.
  Basicamente si quieres escribir o leer unos bytes en un \"archivo\" (Formatear, Copiar al usb, Llenar un tunnel ...) es este commando.

  Pero primero planteamos un problema:
  ${cyellow}> cd ~/Test$cend  # Anda a jugar
  ${cyellow}> echo -e \"Secreto de estado:\\\n\\\nChile atacara Argentina\\\n-- Por Bariloche\\\n-- Manana a las 4pm\\\n-- Con 20.000 tropas terestres livianas\\\n\\\nDespues de lleerlo, destruye este mensaje\" > secret.txt$cend  # Escribe un secreto
  ${cyellow}> cat secret.txt$cend  # Leer el mensaje, pide destruirlo, pero primero:
  ${cyellow}> filefrag -v secret.txt$cend  # Anota el intervalo fisico (que no llaman direcion para no confundir con la RAM). Para mi es: 165776360
  ${cyellow}> df$end  # Anota el nombre del dispositivo de la particion de tu /home. Para mi es /dev/nvme0n1p4
  ${cyellow}> cat secret.txt$cend  # Lee el archivo del system de archivo (en el espacio usario)
  ${cyellow}> sudo dd bs=4k skip=13004623 count=1 if=/dev/nvme0n1p4$cend  # Lee el sector directamente del disco duro (en el espacio kernel)


${cblue}P13: Zero a file (dd): Demostracion del problema$cend
  Pero ahora, boramos el archivo:
  ${cyellow}> rm secret.txt$cend  # Destruye el archivo
  ${cyellow}> cat secret.txt$cend  # Si ya no se ve en el systema de archivo
  ${cyellow}> sudo dd bs=4k skip=13004623 count=1 if=/dev/nvme0n1p4$cend  # Pero todavia se ve en el disco duro

  El commando rm solo destruyo el inode. Por eso puede ser muy rapido (ver ejercicio siguiente: escribir un archivo con random).
  Pero no es muy \"seguro\" porque el contenido del archivo todavia esta en el disco duro. Aun asi, no confies en eso para recuperar tu archivo. Pero no estas seguro que no lo puedan recuperar.
  Para remover el contenido del disco duro, hay que reescribirlo (con zero o random) antes de borrarlo.
  Eso es el ejercicio siguiente:


${cblue}P14: Zero a file (dd): Forma dura$cend
  Se puede reescribir directamente del disco duro:

  !! Cuidado !! No corres este commando si verificar 7 veces. Puede ser aun peor que el famos rm de la muerte
  ${cyellow}> # sudo dd bs=4k count=1 if=/dev/zero of=/dev/nvme0n1p4 seek=33751605 $cend
  Disk Dump
  ByteS: Tamano de un sector mas o menos
  Count: Cuantas veces (1) porque el file pointer avanza
  Input File
  Output File
  Seek: Busca el offset en el output file antes de escribir, es como el skip del output file

  Lo precedente es super complicado y peligroso. Pero ha sido necesario en un SSD. Pero tum como tienes un HD, puedes intentar (sin miedo) lo siguiente:
  ${cyellow}> shred -zvu -n 5 secret.txt$cend
  Y verifica que se borro bien del Disco Duro y no solo del systema de archivo

  Entendiste como hemos usado ${cblue}/dev/zero$cend.
  De la misma forma podemos usar ${cblue}/dev/urandom$cend.
  Cual es la differencia?


${cblue}P15: Zero a file (dd): Usa el manual$cend
  De que sirven la opciones z, v y u de ${cblue}shred$cend?


${cblue}P16: Crear un archivo grande$cend
  ${cyellow}> time dd iflag=fullblock if=/dev/urandom of=big_file.txt bs=32M count=16$cend
  Aumenta el tamano el numero de cuenta (count) si es demasiado rapido

  ${cyellow}> ls -lh big_file.txt$cend  # Que tamano es?

  Aparte sobre el sig pipe:
  Mira un poco el archivo:
  ${cyellow}> cat big_file.txt | head$cend  # Nota que el commando termina muy rapido
  ${cyellow}> cat big_file.txt$cend  # Se demora muchisimo => Ctrl-c
  Te afirmo que el commando ${cblue}cat$cend se termino muy rapido porque head le mando una senal de \"Tubo Quebrado\".
  Dime cual es el numero de la senal \"tubo quebrado\". Indicio: 1/ traduscalo en ingles, 2/ ${cblue}man 7 signal$cend, 3/ Buscar (con \"/\") la traducion en ingles.
  Fin del aparte

  Hypothesis: que esperas de este commando Sera lento o rapido?
  ${cyellow}> time rm big_file.txt$cend
  Validacion: tenia razon en tu hypothesis? Porque?

  ${cyellow}> time dd iflag=fullblock if=/dev/urandom of=big_file.txt bs=32M count=16$cend
  Hypothesis: que esperas de este commando Sera lento o rapido (Nota yo me equivoque)?
  ${cyellow}> cat big_file.txt > /dev/null$cend
  Validacion?


${cblue}P17: Aleatorio (\$RANDOM)$end
  Para los flojos:
  ${cyellow}> echo \$RANDOM$cend

  Para algo mas serio
  ${cyellow}> cat /dev/urandom$cend  # Ctrl-c, sino jamas se acaba

  La pregunta es, de donde saca aleatorio una machina determinista.
  La repuest es del procesador o de la tajeta madre. Puedes ver como se llama el dispositivo con:
  ${cyellow}> cat /sys/devices/virtual/misc/hw_random/rng_available$cend
  o
  ${cyellow}> cat /sys/class/misc/hw_random/rng_available$cend

  El nucleo saca el aleatorio de este dispositivo, creando por comodidad un otro dispositivo (un espiece de alias) que se llama ${cblue}/dev/hwrng$cend. Para HardWare Random Number Generator.

  Puedes generar numeros aleatorio a un nivel mas bajo (nivel kernel) con
  ${cyellow}> sudo head -c 32 /dev/hwrng | hexdump$cend  # Donde puse el (${cyellos}> hexdump$cend$cend) solo para que se pueda leer (encodificado en numeros hexadecimales)

  O el commando dd
  ${cyellow}> sudo dd if=/dev/hwrng of=random.txt bs=1024 count=8$cend
  ${cyellow}> cat random.txt$cend

  Nota que leer /dev/hwrng es muchisimo mas lento que leer /dev/urandom porque toma solo los numeros primordiales de la base de entropia, y no los expande como /dev/urandom.

  Todo eso sirve para la cryptografia. Que se puede ver en https, ssh, passwd y systema de archivos ecryyptados (puede ser todo el disco duro, un pdf, un archivo cualquiera, un falso archivo que simula un systema de arvhivo [en este caso hay que hacer tubos en el nucleo = pilotos])

  De todo eso, solo recuerda ${cblue}/dev/urandom$cend


${cblue}End:$cend
  Felicitacion!

  Hemos visto:
  -- ps, pstree, subshell (fork), exec
  -- /dev/null, /dev/zero, /dev/urandom

  Maniana veremos: monolineas

  Pero antes, tendermos la prueba de medio cyclo

  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
