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

${blue}P01: Quien soy (whoami)$end
  ${cyellow}> whoami$cend
  ${cyellow}> echo $USER$cend


${blue}P02: Quien conoce esta machine (/etc/passwd)$end
  ${cyellow}> cat /etc/password$cend
  ${cyellow}> cat /etc/passwd | awk -F: '{print $1}' | sort$cend
  ${cyellow}> cat /etc/passwd | grep "^$USER\|^root:"$cend


${blue}P03: Quien esta en esta machina (w)$end
  ${cyellow}> who$cend
  ${cyellow}> w  # mas informacion$cend


${blue}P04: Cual es esta machina (hostname)$end
  ${cyellow}> uname -a$cend

  Nota que desde aqui, empezamos a considerar la maquina relativa a su entorno, asi que eso puede cambiar si la machina cambia de lugar.
  En toda esta clase, nos quedarmos en la red local (de la casa) (192.128.0.1) porque es mas seguro

  ${cyellow}> hostname -I$cend
  ${cyellow}> ip address$cend
  ${cyellow}> ifconfig -a$cend  # ya no se usa


${blue}P06: Que puertos estan abiertos aqui (defensa nivel 1)$end
  ${cyellow}> sudo netstat -laputen$cend   # maybe you must run> apt install net-tools

  Pensar NETwork STATistic la pute (puta en frances), son muchas opciones para tener muchas informaciones

  ${cyellow}> sudo ss -tlunp$cend  # Lo mismo despues de 2018

  Pero como todo es arvhivo

  ${cyellow}> sudo lsof -nP -i$cend
  LiSt Open File


${blue}P07: Que pasa en wikipedia.com (ataque nivel 1)$end
  ${cyellow}> ping wikipedia.com$cend
  ${cyellow}> whois 208.80.154.232$cend  # Donde 208.80.154.232 es el IP que se obtiene con ping



${blue}P05:$end
  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
