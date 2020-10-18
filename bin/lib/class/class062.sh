#!/usr/bin/env bash
# -- Tarea: Monolinea: Ciclo de vida del desarrollo de programas

#
# shellcheck disable=SC2154  # cblue is referenced but not
# shellcheck disable=SC2119,SC2120  # abat is called without args

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  echo -e "$cblue
+==================+
| Monolinea: Tarea |
+==================+$cend

Educar no es llenar un balde, sino encender un fuego. (Montaigne)
Cabros esto no prendió. (Clemente Pérez)
El fuego tiene que \"estar y (per)durar\". (Legion extrangera)
Y para eso, aprender y trabajar tiene que ser divertido. Ver Gamification. (Microsoft)

En esta clase, vamos a hacer un utilitario para leer bytebeats!


${cblue}P00: Plan$cend
  Seguiremos el Ciclo de vida del desarrollo de programas:
  1. Ideas:
    a. Un proyecto, util, incemental
    b. Algo ludico, artistico o interactivo, visual, auditivo
    c. Algo en la terminal en un solo idioma
    => Ya esta decidido, un lector de musica!
  2. Requerimientos:
    a. Que no exista ya, y que se pueda vender
    b. Correr en Termux y Linux,
    c. Tener una interface sencilla
    d. Tener melodia ya cargadas y poder agragar otras
    e. Dejar espacio para mejoras (tipo guardar musicas)
  3. Diseno:
    a. Separar el codigo de los datos
    b. Leer musica segun un tubo hasta el lector:
       Asi ningun archivo temporario es necesario
    c. Usar ${cblue}dialog$cend para la interface terminal
  4. Desarollo:
    * Methodologia Agil
  5. Testeo:
    * Paso a Paso, en el plan de fases
  6. Desplegamiento:
    * Termux y Linux, tambien en 192.168.0.9
  7. Mantenimiento
    * Depdendera de los errores del curso

  Lo que hay que recordar de todo eso es: ${cblue}no precipitarse y escribir codigo enseguida$cend.
  De hecho en la misma escritura del codigo, se empiezza con commentarios y prototypos.


${cblue}P01: Instalar Termux sobre Android$cend
  Termux es un emulador de terminal en Android.
  Como es dificil ser el usario raiz (root) en Android, hay algunas differencias.
  Las aplicaciones de Termux corren basicamente en un entorno chroot (mas siguiente clase).
  Mas Ahi: https://wiki.termux.com/wiki/Differences_from_Linux
  
  1/ En tu celuar: Instalala esta aplicacion!
  2/ En Termux: installa openssh-server
  3/ En Termux: corre sshd
  4/ En Termux: ip address
  5/ En Lubuntu: Connectate a Termux:
    > ssh -p 8022 192.168.0.5
    Mas: https://wiki.termux.com/wiki/Remote_Access
  

${cblue}P02: ALSA, OSS and SOX$cend
  OSS: Open Sound System, es la antigua technologia que usaban los unix para correr sonido, se usa mediante lectura/escritura en /dev/dsp
  ALSA: Advanced Linux Sound Architecture, es el nuevo systema de sonido en el nucleo Linux. Donde esta Linux esta alsa. Se usa 
  SOX: Sound eXchange: La navaja suiza de manipulación de audio (apt install sox)

  Nuestro problema aqui es que la interface (nucleo) de alsa no es disponible porque 1/ esta encapsulada en algo privado de google y 2, el nucleo no es disponible dirtamente por no ser root.
  Desafortunamente, el commndo ${cblue}aplay$cend (for alsa lee), ya no existe en Termux. Tenemos que usar sox que es mas versatil y desplegable.
  En la linea:

  "
abat << 'EHD'
for((t=0;;t++));do((n=(
(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
), d=n%255,a=d/64,r=(d%64),b=r/8,c=r%8));printf '%b' "\\$a$b$c";done| aplay 
EHD
  echo -e "

  Remplazamos el tubo final: \"| alsa\" por \"| sox -t raw -b 8 -e unsigned -c 1 -r 8000 - -t wav - | play -\"

  Lo que nos da 
  "
abat << 'EHD'
for((t=0;;t++));do((n=(
(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
), d=n%255,a=d/64,r=(d%64),b=r/8,c=r%8));printf '%b' "\\$a$b$c";done|\
sox -t raw -b 8 -e signed -c 1 -r 8000 - -t wav - | play -
EHD
  echo -e "


${cblue}P03:bytebeat, una funcion de lectura$cend
  Si \"aplay\" es presente, lo usamos, sino usamos la linea enorme de sox.
  Esta vez, lo escribo yo. Podras Volver aqui en la clase 8,
  Abre un archivo \"zik.sh\". Por ejemplo ${cyellow}> xdg-open .$cend, boton derecho create file.

  ${cred}Importante:$cend Tu archivo debe emprezar (primera linea) por el ${cblue}shebang$cend: ${cyellow}#!/bin/bash$cend que dice a linux que interpretador debe correr para executar este codigo.
  Tambien debe tener el derecho de execucion ${cyellow}> chmod +x zih.sh$cend.
  "
abat << 'EHD'
  #!/bin/bash

  echo "Executing $0"
EHD
  echo -e "

  Guardalo, ejecutalo ${cyellow}> bash zik.sh$cend o simplemente ${cyellow}> zik.sh$cend. El segundo commando funciona solo porque 1/ El archivo es ejecutble y 2/ pusiste un shebang.
  \$0 se refiere al commando executado, \$1 al preimer argumento, \$2 al segundo ...

  En zik.sh, escribe la funcion (entre la felchas):
  -->"
abat << 'EHD'
byteplay(){
  # Play the equation given as parameter
  # TODO make the function works on Termux
  for((t=0;;t++));do((n=(
  ((t >> 10) & 42) * t
  ), d=n%255,a=d/64,r=(d%64),b=r/8,c=r%8));printf '%b' "\\$a$b$c";done| aplay 
}

# We call the function for testing
# TODO removes me
byteplay 't*(42&t>>10)'
EHD
  echo -e "
  <-- 
  
  Ejecuta el script!
  Anota hemos escrito commentarios, unos con TODO para no olvidar lo que queda por hacer.
  Volveremos ahi despues.
  Eemovuever la llamada ( las 3 ultimas lineas y corre en el shell:
  "
abat << 'EHD'
source zik.sh  # incluye la funcion en tu shell
bytebeat 't*(42&t>>10)'  # Corre la funcion
EHD
  echo -e "


${cblue}P05: La interface$cend
  Podemos correr musica, ahora hay que dejar el usario elejir que quiere correr.
  Como trabajamos con mejorar incrementales, vamos a incluir la lista en el codigo.
  --> "
abat << 'EHD'
bytegui(){
  # Ask user for the equation to play (in list)
  # Require: dialog

  # Define list (with associative array)
  declare -A bytelist=(
    ['42 melody']='t*(42&t>>10)'
    ['Sierpinski']='t & t/256'
    ['StarLost']='((t % 255) ^ (t % 511)) * 3'
    ['Mistery Trans']='(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)'
  )

  # Create array with boeth key and value, to give to dialog
  declare -a bytekeyval
  for key in "${!bytelist[@]}"; do
    bytekeyval+=("$key" "${bytelist[$key]}")
  done
  
  # Get user input
  name=$(dialog \
    --backtitle "ByteBeater" \
    --clear \
    --menu "Choose equation to bytebeat!" 0 0 "${#bytelist}" \
    "${bytekeyval[@]}" \
    --output-fd 1 \
  )

  # Play melody
  equation="${bytelist[$name]}"
  echo "Playing: $name => $equation"
  byteplay "$equation"
}

bytegui
EHD
  echo -e "
  <--

  Ejecuta: ${cyellow}> bash zik.sh$cend
  Hicimos casi una iteracion de desarollo incremental:
    falta el desplegar que no mostraria que no funciona en Android
  Functiona? Que bueno, si es el caso, es un buen momento para una pausa.

  Antes de la pausa, preparamos lo que haremos despues, asi las ideas vendran sola.
  1/ Que funcione en Android
  2/ Separar el codigo de los datos (tener un archivo de datos)
  3/ Deplegar en Android


${cblue}P06: Lector de muscia mas versatil$cend

${cblue}P99: Proponer ideas$cend
  El ciclo acabado, se puede proponer mejoras al usario pero esperar su opinion, antes de implementarlas
  - Subir a una pagina web
  - Permitir al usario entrar ecuaciones
    - Con dialog o url (si en pagina web)
    - Guardar las nuevas ecauciones: en archivo o coookie (si web)
  - Mas botones|teclas: q para salir, m para volver al menu
  - Interface visual que muesta las \"notas\" que estan corriendo

  Una vez el usario valido una mejoras, se empieza un nuevo ciclo agil de desarollo


${cblue}End:$cend
  Hemos visto:
    - Para ejecutar un script bash, lo puedes correr como 1/ bash script.sh 2/ ./script.sh 3/ script.sh  # si su directorio esta en \$PATH 4/ source script.sh

  "
}

abat(){
  `# alias_bat laguage < stdin > stdout`
  local lang="${1:-bash}"
  bat --style plain --color always --pager "" --language "$lang" - | perl -p -e 'chomp if eof';
}

list_bytebeat(){
  echo '
  t*(42&t>>42)  # 42 melody
  '
}


get_fct_dic
call_fct_arg "$@"
