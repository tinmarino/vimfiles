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
El fuego tiene que \"estar y (per)durar\". (Legión extranjera)
Y para eso, aprender y trabajar tiene que ser divertido. Ver gamificacion. (Microsoft)

En esta clase, vamos a hacer un utilitario para leer bytebeats!


${cblue}P00: Plan$cend
  Seguiremos el Ciclo de vida del desarrollo de programas:
  1. Ideas:
    a. Un proyecto, útil, incremental
    b. Algo lúdico, artístico o interactivo, visual, auditivo
    c. Algo en la terminal en un solo idioma
    => Ya esta decidido, un lector de música!
  2. Requerimientos:
    a. Que no exista ya, y que se pueda vender
    b. Correr en Termux y Linux,
    c. Tener una interfase sencilla
    d. Tener melodía ya cargadas y poder agarrar otras
    e. Dejar espacio para mejoras (tipo guardar músicas)
  3. Diseño:
    a. Separar el código de los datos
    b. Leer música según un tubo hasta el lector:
       Así ningún archivo temporario es necesario
    c. Usar ${cblue}dialog$cend para la interfase terminal
  4. Desarrollo:
    * Metodología Ágil
  5. Testeo:
    * Paso a Paso, en el plan de fases
  6. Despliegue:
    * Termux y Linux, también en 192.168.0.9
  7. Mantenimiento
    * Deprenderá de los errores del curso

  Lo que hay que recordar de todo eso es: ${cblue}no precipitarse y escribir código enseguida$cend.
  De hecho en la misma escritura del código, se empieza con comentarios y prototipos.


${cblue}P01: Instalar Termux sobre Android$cend
  Termux es un emulador de terminal en Android.
  Como es difícil ser el usuario raíz (root) en Android, hay algunas diferencias.
  Las aplicaciones de Termux corren básicamente en un entorno con cambio de raíz (mas siguiente clase).
  Mas Ahi: https://wiki.termux.com/wiki/Differences_from_Linux

  Hacker's Keyboard es un teclado completo, con las flechas direccionales, Ctrl, Esc ...

  1/ En tu celular: Instala Termux
  1/ En tu celular: Instala Hacker's Keyboard
  2/ En Termux: instala \"sox\"
  3/ En Termux: instala \"openssh-server\"
  4/ En Termux: \"ip address\"
  5/ En Termux: corre \"sshd\"
  6/ En Lubuntu: Connectate a Termux:
    ${cyellow}> ssh -p 8022 192.168.0.5$cend
    Mas: https://wiki.termux.com/wiki/Remote_Access


${cblue}P02: ALSA, OSS and SOX$cend
  OSS: Open Sound System, es la antigua tecnología que usaban los Unix para correr sonido, se usa mediante lectura/escritura en /dev/dsp
  ALSA: Advanced Linux Sound Architecture, es el nuevo sistema de sonido en el núcleo Linux. Donde esta Linux esta Alsa. Se usa
  SOX: Sound eXchange: La navaja suiza de manipulación de audio (apt install sox)

  Nuestro problema aquí es que la interfase (núcleo) de Alsa no es disponible porque 1/ esta encapsulada en algo privado de Google y 2, el núcleo no es disponible directamente por no ser root.
  Desafortunadamente, el comando ${cblue}aplay$cend (para alsa lee), ya no existe en Termux. Tenemos que usar sox que es mas versátil y desplegable.
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


${cblue}P03:bytebeat, una función de lectura$cend
  Si \"aplay\" es presente, lo usamos, sino usamos la linea enorme de sox.
  Esta vez, lo escribo yo. Podrás Volver aquí en la clase 8,
  Abre un archivo \"zik.sh\". Por ejemplo ${cyellow}> xdg-open .$cend, botón derecho create file.

  ${cred}Importante:$cend Tu archivo debe empezar (primera linea) por el ${cblue}shebang$cend: ${cyellow}#!/bin/bash$cend que dice a Linux que interpretador debe correr para ejecutar este código.
  También debe tener el derecho de ejecución ${cyellow}> chmod +x zih.sh$cend.
  "
abat << 'EHD'
  #!/bin/bash

  echo "Executing $0"
EHD
  echo -e "

  Guárdalo, ejecútalo ${cyellow}> bash zik.sh$cend o simplemente ${cyellow}> zik.sh$cend. El segundo comando funciona solo porque 1/ El archivo es ejecutable y 2/ pusiste un shebang.
  \$0 se refiere al comando ejecutado, \$1 al primer argumento, \$2 al segundo ...

  En zik.sh, escribe la función (entre la flechas):
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
  Anota hemos escrito comentarios, unos con TODO para no olvidar lo que queda por hacer.
  Volveremos ahí después.
  Remover la llamada las 3 ultimas lineas y corre en el shell:
  "
abat << 'EHD'
source zik.sh  # incluye la funcion en tu shell
bytebeat 't*(42&t>>10)'  # Corre la funcion
EHD
  echo -e "


${cblue}P05: La interfase$cend
  Podemos correr música, ahora hay que dejar el usuario elegir que quiere correr.
  Como trabajamos con mejorar incrementales, vamos a incluir la lista en el código.
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

  # Create array with both key and value, to give to dialog
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
  Hicimos casi una iteración de desarrollo incremental:
    falta el desplegar que no mostraría que no funciona en Android
  Funciona? Que bueno, si es el caso, es un buen momento para una pausa.

  Antes de la pausa, preparamos lo que haremos después, así las ideas vendrán sola.
  1/ Que funcione en Android
  2/ Separar el código de los datos (tener un archivo de datos)
  3/ Desplegar en Android


${cblue}P06: Lector de música mas versátil$cend
  Hemos visto (P02) que \"aplay\" no funciona en Termux.
  Si \"aplay\" no esta presente, tenemos que usar \"sox\"
  Remplaza la función byteplay por la siguiente donde el comando del lector es una variable (evaluado para que el tubo se ejecute => eso esta afuera del enfoque de esta clase)

  -->"
abat << 'EHD'
byteplay(){
  # Determine the sound reader present
  cmd="aplay"
  # If aplay exists (Linux) => just pass
  if command -v aplay > /dev/null; then
    :
  # Else, If sox command exists (Android) => use the big, hacky pipe
  elif command -v sox > /dev/null; then
    cmd="sox -t raw -b 8 -e signed -c 1 -r 8000 - -t wav - | play -"
  # Otherwise (Problem) => Notify user to install sox (in StdErr)
  else
    >&2 echo "ERROR: Cannot reproduce music on your device !"
    >&2 echo "Please install sox => apt install sox"
    exit 1
  fi

  # Play the equation given as parameter
  for((t=0;;t++));do((n=(
  $1
  ), d=n%255,a=d/64,r=(d%64),b=r/8,c=r%8));printf '%b' "\\$a$b$c"; done | eval $cmd
}
EHD
  echo -e "
  <--

  Todavía funciona en Linux ?


${cblue}P07: Separación códigos / datos$cend
  Hemos escrito los datos (canciones) directamente en una cuadra Bash con la sintaxis especifica de Bash, ahí:
"
abat << 'EHD'
  # Define list (with associative array)
  declare -A bytelist=(
    ['42 melody']='t*(42&t>>10)'
    ['Sierpinski']='t & t/256'
    ['StarLost']='((t % 255) ^ (t % 511)) * 3'
    ['Mistery Trans']='(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)'
  )
EHD
  echo -e "

  Eso Se llamar hardcode o incluir en duro los datos y esta muy mal!
  La dificultad para: agregar canciones, compartir los datos con un programa, digamos en JavaScript son unos ejemplos de lo malo que es: hay 40 ejemplos mas.
  Es casi la regla 1 => Separa los datos del código!

  Ok, Ok, tranquilo profe, lo vamos a separar.
  Aqui, igual dejaremos los datos en el archivo zik.sh asi sera mas facil transportar, pero lo vamos a poner en un formato independiente del idioma (aqui Bash).
  El formato sera: \"Nombre de la muscia : ecuacion\" osea usaremos un \":\" como separador. Como para la variable de entorno \$PATH, no me crees => ${cyellow}> echo \$PATH$cend.

  Primero Escribe la lista => Copia esta función arriba del archivo zik.sh
  -->"
abat << 'EHD'
listtube(){
  # Using "Here Document"
  cat << 'EOH'
    42 melody      : t*(42&t>>10)
    Sierpinski     : t & t/256
    StarLost       : ((t % 255) ^ (t % 511)) * 3
    Mistery Trans  : (t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
    Hard Carry     : t*(t^t+(t>>15|1)^(t-1280^t)>>10)
    DickJockey     : (t*(t>>5|t>>8))>>(t>>16)
    Nimpho Piano   : t*(((t>>9)&10)|((t>>11)&24)^((t>>10)&15&(t>>15)))
EOH
}
EHD
  echo -e "
  <--

  Despues remplaza la definicion de bytelist (citado arriba) en bytegui.
  Replazala por

  -->"
abat << 'EHD'
  # Define list (with associative array) <= tubelist
  declare -A bytelist=()
  while read -r line; do
    # Get key <= before the first ":"
    key="${line%%:*}"
    # Remove trailing whitespace characters
    key="${key%"${key##*[![:space:]]}"}"

    # Get value <= after the first ":"
    value="${line#*: }"

    # Set array
    bytelist[$key]="$value"
  done <<< "$(listtube)"
EHD
  echo -e "
  <--

  Donde vez, al final que el ciclo toma como entrada la substitución de comando de listtube, la función que definiste.
  Este símbolo \"<<<\" significa un Here String. Hice este código con una retiración y no un tubo porque el tubo crea un subshell del cual no pude sacar la variable bytelist. Lo que es desafortunado ya que era el objetivo. Acuérdate que los subshells no pueden modificar las variables de sus padres y que los tubos generan subshells


${cblue}P08: Resultado final$cend
  Casi terminaste el segundo ciclo de desarrollo. Hagamos una sincronización.
  El código debería ser parecido a:
"
abat << 'EHD'
#!/usr/bin/env bash

listtube(){
  # Using "Here Document"
  cat << 'EOH'
    42 melody      : t*(42&t>>10)
    Sierpinski     : t & t/256
    StarLost       : ((t % 255) ^ (t % 511)) * 3
    Mistery Trans  : (t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
    Hard Carry     : t*(t^t+(t>>15|1)^(t-1280^t)>>10)
    DickJockey     : (t*(t>>5|t>>8))>>(t>>16)
    Nimpho Piano   : t*(((t>>9)&10)|((t>>11)&24)^((t>>10)&15&(t>>15)))
EOH
}

byteplay(){
  # Determine the sound reader present
  cmd="aplay"
  # If aplay exists (Linux) => just pass
  if command -v aplay > /dev/null; then
    :
  # Else, If sox command exists (Android) => use the big, hacky pipe
  elif command -v sox > /dev/null; then
    cmd="sox -t raw -b 8 -e signed -c 1 -r 8000 - -t wav - | play -"
  # Otherwise (Problem) => Notify user to install sox (in StdErr)
  else
    >&2 echo "ERROR: Cannot reproduce music on your device !"
    >&2 echo "Please install sox => apt install sox"
    exit 1
  fi

  # Play the equation given as parameter
  for((t=0;;t++));do((n=(
  $1
  ), d=n%255,a=d/64,r=(d%64),b=r/8,c=r%8));printf '%b' "\\$a$b$c"; done | eval $cmd
}

bytegui(){
  # Ask user for the equation to play (in list)
  # Require: dialog

  # Define list (with associative array) <= tubelist
  declare -A bytelist=()
  while read -r line; do
    # Get key <= before the first ":"
    key="${line%%:*}"
    # Remove trailing whitespace characters
    key="${key%"${key##*[![:space:]]}"}"

    # Get value <= after the first ":"
    value="${line#*: }"

    # Set array
    bytelist[$key]="$value"
  done <<< "$(listtube)"

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

exit 0
EHD
  echo -e "


${cblue}P08: Despliegue en Termux$cend
  Copia este código hasta Termux y ejecútalo ahí:

  En Linux:
  ${cyellow}> ip address$cend
  Debieria darte algo como 192.168.0.14 si no es el caso remplazalo, si no tienes la mascara de red 192.168 es que tu adaptador de red VirtualBox no esta en modo puente. Recofiguralo.

  En Termux:
  ${cyellow}scp jim@192.168.0.14:Test/zik.sh .$cend
  Remplaza el IP y el camino si necesario.
  Entra la clave
  Te deberia aparecer un zik.sh en el \$PWD.
  ${cyellow}> ls$cend
  ${cyellow}> bash zik.sh$cend


${cblue}P99: Proponer ideas$cend
  El ciclo acabado, se puede proponer mejoras al usuario pero esperar su opinión, antes de implementarlas
  - Subir a una pagina web
  - Permitir al usuario entrar ecuaciones
    - Con dialog o url (si en pagina web)
    - Guardar las nuevas ecuaciones: en archivo o coookie (si web)
  - Mas botones|teclas: q para salir, m para volver al menu
  - Interfase visual que muestra las \"notas\" que están corriendo

  Una vez el usuario valido una mejoras, se empieza un nuevo ciclo ágil de desarrollo


${cblue}End:$cend
  Felicitación, ahora puedes escuchar y componer música en tu celular sin necesidad de tener acceso a la red!
  Ademas, tienes todo las herramientas y la metodología para mejorarlo.

  Hemos visto:
    - Para ejecutar un script bash, lo puedes correr como 1/ bash script.sh 2/ ./script.sh 3/ script.sh  # si su directorio esta en \$PATH 4/ source script.sh

  Esta noche veremos: Herramientas del Desarrollador operacional: Contenedores y Synchronizadores => Docker y Git.
  "
}

list_bytebeat(){
  echo '
  t*(42&t>>42)  # 42 melody
  '
}


get_fct_dic
call_fct_arg "$@"
