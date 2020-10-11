#!/usr/bin/env bash
# ${cblue}System: Explore$cend: Process, Device: pstree, /dev/zero
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+==========================+
| Parte 1 Explore: Process |
+==========================+$cend

${cblue}P01: Arbol de processos (pstree)$cend
  ${cyellow}> pstree -alp$cend  # -a = muestra la linea de commando del commando, -l = formato largo, -p = muestra el PID

  Redirecionalo en un archivo y lee el archivo
  ${cyellow}> pstree -alp > process_tree.txt$cend
  ${cyellow}> xdg-open process_tree.txt$cend

  Encuentra tu propio processo: pstree y sus padres
  
  De forma mas sencilla:
  ${cyellow}> pstree -al -s \$\$$cend
  Muestra especificamente el proceso con PID \$\$ es decir el presente Shell

  ${cyellow}> man systemd$cend


$cblue
+==========================+
| Parte 2 Explore: Device  |
+==========================+$cend

${cblue}P11: Zero a file (dd): descripcion de filefrag$cend
  ${cblue}dd$end significa \"Disk Dump\". Es un commando como cat orientado a los byte y no a los caracteres imprimible. Es mas bajo nivel => mas dificil de usar pero tiene mas utilidades potencilaes.
  Masicamente si quieres escribir o leer unos bytes en un \"archivo\" (Formatear, Copiar al usb, Llenar un tunnel ...) es este commando.

  Pero primero planteamos un problema:
  ${cyellow}> cd ~/Test$cend  # Anda a jugar
  ${cyellow}> echo -e \"Secreto de estado:\\\n\\\nChile atacara Argentina\\\n-- Por Bariloche\\\n-- Maniana a las 4pm\\\n-- Con 20.000 tropas terestres livianas\\\n\\\nDespues de llerlo, destruye este mensaje\" > secret.txt$cend  # Escribe un secreto
  ${cyellow}> cat secret.txt$cend  # Leer el mensaje, pide destruirlo, pero primero:
  ${cyellow}filefrag -v secret.txt$cend  # Anota el intervalo fisico (que no llaman direcion para no confundir con la RAM). Para mi es: 165776360
  ${cyellow}> df$end  # Anota el nombre del dispositivo de la particion de tu /home. Para mi es /dev/nvme0n1p4
  ${cyellow}> cat secret.txt$cend  # Lee el archivo del system de archivo (en el espacio usario)
  ${cyellow}> sudo dd bs=4k skip=13004623 count=1 if=/dev/nvme0n1p4$cend  # Lee el sector directamente del disco duro (en el espacio kernel)
  

${cblue}P12: Zero a file (dd): Demostracion del problema$cend
  Pero ahora, boramos el archivo:
  ${cyellow}> rm secret.txt$cend  # Destruye el archivo
  ${cyellow}> cat secret.txt$cend  # Si ya no se ve en el systema de archivo
  ${cyellow}> sudo dd bs=4k skip=13004623 count=1 if=/dev/nvme0n1p4$cend  # Pero todavia se ve en el disco duro

  El commando rm solo destruyo el inode. Por eso puede ser muy rapido (ver ejercicio siguiente: escribir un archivo con random).
  Pero no es muy \"seguro\" porque el contenido del archivo tadavia esta en el disco duro. Aun asi, no confies en eso para recuperar tu archivo. Pero no estas seguro que no lo puedan recuperar.
  Para remover el contenido del disco duro, hay que reescribirlo (con zero o random) antes de borrarlo.
  Eso es el ejercicio siguiente:


${cblue}P13: Zero a file (dd): Forma dura$cend
  Se puede reescribir directamente del disco duro:

  !! Cuidado !! No corres este commando si verificar 7 veces. Puede ser aun peor que el famos rm de la muerte
 sudo dd bs=4k skip=33751605 count=1 if=/dev/zero of=/dev/nvme0n1p4 seek=33751605
  ${cyellow}> # sudo dd bs=4k count=1 if=/dev/zero of=/dev/nvme0n1p4 seek=33751605 $cend
  Disk Dump
  ByteS: Tamano de un sector mas o menos
  Count: Cuantas veces (1) porque el file pointer avanza
  Input File
  Output File
  Seek: Busca el offset en el output file antes de escribir, es como el seek del output file

  Lo precedente es super complicado y peligroso. Pero ha sido necesario en un SSD. Pero tum como tienes un HD, puedes intentar (sin miedo) lo siguiente:
  ${cyellow}> shred -zvu -n 5 secret.txt$cend
  Y verifica que se borro bien del Disco Duro y no solo del systema de archivo

  Entendiste como hemos usado ${cblue}/dev/zero$cend.
  De la misma forma podemos usar ${cblue}/dev/urandom$cend.
  Cual es la differencia?


${cblue}P14: Zero a file (dd): Usa el manual$cend
  De que sirven la opciones z, v y u de ${cblue}shred$cend?


${cblue}P15: Crear un archivo grande$cend
  ${cyellow}> time dd iflag=fullblock if=/dev/urandom of=big_file.txt bs=32M count=16$cend
  Aumenta el tamano el numero de cuenta (count) si es demasiado rapido

  ${cyellow}> ls -lh big_file.txt$cend  # Que tamano es?

  Aparte sobre el sig pipe:
  Mira un poco el archivo:
  ${cyellow}> cat big_file.txt | head$cend  # Nota que el commando termina muy rapido
  ${cyellow}> cat big_file.txt$cend  # Se demora muchisimo => Ctrl-c
  Te afirmo que el commando ${cblue}cat$end se termino muy rapido porque head le mando una senal de \"Tubo Quebrado\".
  Dime cual es el numero de la senal \"tubo quebrado\". Indicio: 1/ traduscalo en ingles, 2/ $cblueman 7 signal$end, 3/ Buscar (con \"/\") la traducion en ingles.
  Fin del aparte

  Hypothesis: que esperas de este commando Sera lento o rapido?
  ${cyellow}> time rm big_file.txt$cend
  Validacion: tenia razon en tu hypothesis? Porque?
  
  ${cyellow}> time dd iflag=fullblock if=/dev/urandom of=big_file.txt bs=32M count=16$cend
  Hypothesis: que esperas de este commando Sera lento o rapido (Nota yo me equivoque)?
  ${cyellow}> cat big_file.txt > /dev/null$cend
  Validacion?
  


${cblue}End:$cend

  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
