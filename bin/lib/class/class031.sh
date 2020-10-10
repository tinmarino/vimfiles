#!/usr/bin/env bash
# ${cblue}Clase 031$cend: Usarios y Machinas: La Red
#
# shellcheck disable=SC2154  # cblue is referenced but not
# From: https://cvw.cac.cornell.edu/Linux/exercise
# Link: https://swcarpentry.github.io/shell-novice/04-pipefilter/index.html
# -- Buenisimo: Molecules

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+=============================+
|  User and Machines: Network |
+=============================+$cend

Que es un usario, que es una machina
Son ambos numeros segun la machina y nombre segun el humano.
Una machina, un programa, un humano o un conjuto de esos puede ser usario.
La machina tiene un puerto abirto y puede ejecutar codigo, es mano de obra disponible, el usario es un jefe latente.

$cblue
+================================+
|  Parte 1: Defense your machine |
+================================+$cend

${cblue}P01: Quien soy (whoami)$cend
  ${cyellow}> whoami$cend
  ${cyellow}> echo $USER$cend


${cblue}P02: Quien conoce esta machine (/etc/passwd)$cend
  ${cyellow}> cat /etc/password$cend
  ${cyellow}> cat /etc/passwd | awk -F: '{print $1}' | sort$cend
  ${cyellow}> cat /etc/passwd | grep "^$USER\|^root:"$cend


${cblue}P03: Quien esta en esta machina (w)$cend
  ${cyellow}> who$cend
  ${cyellow}> w  # mas informacion$cend


${cblue}P04: Cual es esta machina (hostname)$cend
  ${cyellow}> uname -a$cend

  Nota que desde aqui, empezamos a considerar la maquina relativa a su entorno, asi que eso puede cambiar si la machina cambia de lugar.
  En toda esta clase, nos quedarmos en la red local (de la casa) (192.128.0.1) porque es mas seguro

  ${cyellow}> hostname -I$cend
  ${cyellow}> ip address$cend
  ${cyellow}> ifconfig -a$cend  # ya no se usa


${cblue}P06: Que puertos estan abiertos aqui (defensa nivel 1)$cend
  ${cyellow}> sudo netstat -laputen$cend   # maybe you must run> apt install net-tools

  Pensar NETwork STATistic la pute (puta en frances), son muchas opciones para tener muchas informaciones

  ${cyellow}> sudo ss -tlunp$cend  # Lo mismo despues de 2018

  Pero como todo es arvhivo

  ${cyellow}> sudo lsof -nP -i$cend
  LiSt Open File

${cblue}P07: Que pasa en wikipedia.com (ataque nivel 1)$cend
  ${cyellow}> ping wikipedia.com$cend
  ${cyellow}> whois 208.80.154.232$cend  # Donde 208.80.154.232 es el IP que se obtiene con ping

${cblue}P08: Descargar desde wikipedia.com usando falso archivos$cend
  Eso ya se esta poniendo complicado a mano.
  Un ejemplo pre 2000
  ${cyellow}> exec 3<>/dev/tcp/www.het.brown.edu/80;$cend  # \"Solo\" pido enchufar el \"archivo aparato\" al file descriptor 3
  ${cyellow}> echo -e \"GET /guide/UNIX-password-security.txt\\\r\\\n\" >&3;$cend  # Mando un GET request escribiendo
  ${cyellow}> cat <&3$cend  # Ahora leo el retorno leyendo

${cblue}P09: Descargar desde wikipedia.com (wget)$cend
  Ahora con HTTPS y para descargar sitios enteros ... mejor usar una heramienta
  ${cyellow}> wget https://en.wikipedia.org/wiki/Unix_philosophy$cend
  Web GET. Que obviamento debes instalar con
  ${cyellow}> sudo apt install wget$cend


$cblue
+================================+
|  Parte 2: Attack my machine    |
+================================+$cend

${cblue}P21: Ok vamos (SSH)$cend
  Puedes ver la lista de las machinas con ${cyellow}jim class031 system_map$cend
  ${cyellow}> ssh 192.168.0.9$cend
  Bienvenido en mi maquina personal Jim

  ${cyellow}> whoami; hostname$cend  # aprecia que \";\" separa los commandos

${cblue}P22: Rapatriar (SCP)$cend
  Para tenerlo en tu machina
  ${cyellow}> scp jim@192.168.0.9:Test/Jim/secret.md secret_local.md$cend


${cblue}P25:$cend
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

get_fct_dic
call_fct_arg "$@"
