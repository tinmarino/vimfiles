#!/usr/bin/env bash
# ${cblue}Clase 032$cend: Red: Trabajo en casa
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+==============================+
|  User and Machines: Homework |
+==============================+$cend

${cblue}P01: Un poco de calle (Route)$cend
  Seguir el ejercicio de 10 commandos ahi:
  https://www.geeksforgeeks.org/route-command-in-linux-with-examples/
  Pero primero, guadar la table de ruteo:
  ${cyellow}> route > route_save.txt$cend


${cblue}P02: Sal de tu casa (IP externa)$end
  Has visto ${cyellow}hostname -I$cend, ${cyellow}ip adrress$cend, or (${cyellow}ifconfig$cend en linux or ${cyellow}ipconfig$cend en window).
  Pero eso te da solo la IP interna.
  Para pedir la IP externa, pidela a un sitio simpatico (aqui ipinfo)
  ${cblue}curl$cend puede hacer cualquier commando TCP y dar la vuelta en la terminal. Es mas primitivo que ${cblue}wget$cend. Se usa mucho para hacer un simple GET or POST

  ${cyellow}curl https://ipinfo.io/ip$cend
  Te deberia dar, como yo 201.241.56.254

  Aparte sobre lo Local Vs Externo:
  Entonces, del exterior, cual es la differencia entre tu y yo: si los otros (los sitios web) nos ven con la misma IP, como pueden elejir a quien mandan las paginas (Pensar 10 sec).
  Obivamente el puerto! Si yo pido una pagina wikipedia.org desde el puerto 42666 y tu una pagina uber.cl desde el puerto 12345, wikipedia responde al puerto 42666 del router que esta inteligentemente ligado al puerto 42666 de MI machina y advina, uber.cl respondera al puerto 12345 del router que esta iteligentemente ligado al puerto 12345 de TU machina.
  Asi YO no veo TU uber.cl y TU no vez MI wikipedia.
  Fin del aparte.

  Quien es dueno de tu modem (alias router):
  ${cyellow}> whois 201.241.56.254$cend

  En que lugar:
  ${cyellow}curl https://ipvigilante.com/201.241.56.254$cend
  (En mi caso, el sitio cayo, asi que no se en que lugar estoy)


${cblue}P03: Seguir una solicitud (Traceroute)$cend
  ${cyellow}> traceroute www.normandie-tourisme.fr$cend
  La primera linea indica el IP del objectivo, despues, cada line indica el router siguiente en el camino: la pimera indica el router de tu casa y la ultima, el router de la casa del objectivo.

  Son muchos IP, no resulto, prefiero nombres de paices, ciudades: Admira este commando
  ${cyellow}curl https://ipvigilante.com/213.242.127.158$cend

  Eso huele bastante a un ${cblue}Pipe to BaSh$end

  a/ Primero guadamos el StdOutput del commando lento
  ${cyellow}> traceroute -n www.normandie-tourisme.fr > trace.txt$cend

  b/ Saca la primera linea: sed = Stream EDitor, -n = silent = no imprimir cada linea, 2,\$ = para la lineas entre 2 y ultima (incluida), p = print
  ${cyellow}> cat trace.txt | sed -n '2,$ p'$cend

  c/ Saca las lineas sin IP: grep = agara, -v = invert = todo lo que no tiene, dos espacios y una estrella
  ${cyellow}> cat trace.txt | sed -n '2,$ p' | grep -v '  \\*'$cend

  d/ Jugamos con las columnas. Nota que 2> /dev/null significa: redirige el descirptor de archivos 2 (Standard Error) al dispositivo nulo, el agujero negro /dev/null, para no ver los errores de ${cblue}curl$cend
  ${cyellow}> cat trace.txt | sed -n '2,$ p' | grep -v '  \\*' | awk '{print \"echo \" \$1 \" \$(curl ipvigilante.com/\" \$2 \" 2> /dev/null)\" }'$cend

  e/ Ahora si, toma las precausiones adecuadas ( intenta con una o dos lines y ${cblue}Pipe to BaSh$cend
  ${cyellow}> cat trace.txt | sed -n '2,$ p' | grep -v '  \\*' | awk '{print \"echo \" \$1 \" \$(curl ipvigilante.com/\" \$2 \" 2> /dev/null)\" }' | bash$cend


${cblue}P04: Un poco mas pro que ping (dig)$cend
  Te mostre un ping wikipedia.org que uso para saber su IP, tomar, del nombre de dominio el IP se llama DNS lookup (para Domain Name Service). El commando asociado es ${cblue}dig$cend.
  Perdoname, ${cblue}ping$cend siempre ha sido bastante para mi. Te lo digo porque aparece en entrevista de trabajo, es mas pro, mas facil poner en un escript, te puede dar los distintos IP ... mas informaciones ahi: https://linuxize.com/post/how-to-use-dig-command-to-query-dns-in-linux/
  Como simpre, muy facil de usar:
  ${cyellow}> dig wikipedia.org$cend


${cblue}P05: Mas usarios$cend
  Para esta tarea, agrega 1 o 2 usarios a tu machina (voy a verificar) jim2 y jim3 por ejemplo.
  Agrega ${cblue}sudo$cend antes de todo estos commandos.

  ${cyellow}> useradd -m -s /bin/bash jim2$cend
  Crea el usario jim2
    Opcion -m (--create-home) option to create the user home directory as /home/username:
    Opcion -s (--shell) option para especificar el Shell por defecto del usario (sin no lo especificas, usa /bin/sh de 1970 y no bash de 1990-2000, lo que es termible, no hay color ni complecion y hay bug)

  ${cyellow}> passwd jim2$cend
  Dale la clave jim2

  ${cyellow}> useradd -m -s /bin/bash jim3$cend
  ${cyellow}> useradd -m -s /bin/bash jim4$cend
  ${cyellow}cat /etc/passwd$cend
  Se agregaron los usarios? Bakan, bastante jugado sacalos Ya!

  ${cyellow}userdel jim3$cend
  ${cyellow}userdel jim4$cend
  ${cyellow}cat /etc/passwd$cend
  Ya no estan? Que bueno, conserva jim2

  Y connectate (login) como jim2 a tu propia machina
  ${cyellow}> su - jim2$cend  # Dale la clave jim2
  ${cyellow}whoami$cend  # jim2? Bakan
  ${cyellow}exit$cend
  ${cyellow}whoami$cend
  ${cyellow}exit$cend
  Ah ya saliste de tu ultimo subshell, en todo caso, se acabo el ejercicio de hoy.


${cblue}End:$cend
  Hemos visto:
    En clase: whoami (\$USER), hostname (\$HOSTNAME), w, ip, y sobre todo ssh
    En casa: route, traceroute, curl (un poco), dig, useradd, passwd, userdel, (existe usermod pra modificar), la redirecion \"2> /dev/null\" un poco que muestra que una redirecion puede ser de otro descriptor de archivo que el StdOut (aqui el StdErr) y que nos muestra un uso del dispositivo nulo (alias el agujero negro)

  Maniana:
    jobs, fg, bg, pstree, kill, Crl-c, Ctrl-Z, /dev/random, glob, command expansion
    y, si hay tiempo, usar un editor de texto (vim, nano, emacs, GUI text editor), y hacer codigo: ramas (if), ciclos (for) y funciones (function)

    Felicitacion! Hemos hecho muchisimo en 1 semana. En 2 clases mas, empezaremos a ver heramientas mas pesadas para synchronisar (git), descargar (wget), o editar (vim) pero nunca, no Nunca, dejaremos lso tubs y sus poderes (ex: ${cblue}cat file.txt | grep \"text to search\"$cend)
  "

  echo -e "$msg"
}

system_map(){
  local msg="
Mira que el numero corresponde al orden de registramiento en el router: Tu VM es el ultimo
Empiezan con 192.168.0 y sin el 0: Ejemplo: 192.168.0.9

05: Tin Phone  Termux
11: Tin Laptop Ubuntu  Alma
09: Tin Laptop Ubuntu  Personal <--- TARGET
07: Jim Laptop Windows
14: Jim VM     Lubuntu
  "

  echo -e "$msg"
}

references(){
  local msg="
  Useradd: https://www.neoguias.com/crear-usuario-linux-comando-useradd/
  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
