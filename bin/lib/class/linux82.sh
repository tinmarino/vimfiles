#!/usr/bin/env bash
# -- Tarea: wget, cron, cgi, jenkins
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+=================+
| Servidor: Tarea |
+=================+$cend

Hoy vamos a servir!


${cblue}P01: Clonar un sitio (10min)$cend
  Clona este sitio de un amigo mio: https://apple3095842.brizy.site
  Si tienes dudas en como hacerlos, busca \"wget clone full website\"


${cblue}P02: CGI: Common Gateway Interface, BaSh examples (20min)$cend
  Desarolla los dos primeros servicios CGI en BaSh de este sitio:
  http://www.yolinux.com/TUTORIALS/BashShellCgi.html

  Llamalos y averigua que funcionen correctamente


${cblue}P03: Servidor DNS (dovecot)$cend
  TODO


${cblue}P04: Pagina Github (1h30)$cend
  Copia el contenido de mi pagina web en tu computador.
  Me llamo \"Tinmarino\".

  1/ Encuentra mi pagina web en mis 50 repo github (tiene un nombre especifico)
  2/ Descargala en tu maquina
  3/ Abre el index.html con firefox y analisa la paginas.

  4/ Copia lo estricto necesario en tu pagina, remueve los archivos miso (en pdf), remplaza Tinmarino por Jaime. Cuidado, no hagas tu CV en HTML. Te lo voy a generar automaticamente y mandar.
  5/ Mira que archivos cambiaste (Jim)
  6/ Si esta bien, no quedan pruebas de la copia, empujalo (no olvides add y commit antes)


${cblue}P05: Niceness: nice, renice$cenc
  TODO

${cblue}P06: Cron$cenc
  TODO


${cblue}P09: Otros$cenc
  TODO
  > route
  > iptables
  > postfix
  > imap

$cblue
+==========+
| Servicio |
+==========+$cend

${cblue}P11: Crea un servicio CGI para ver archivos (en BaSh)$cend
  https://github.com/tinmarino/abache


${cblue}P12: Manipular dynamicamente los servicios$cend
  TODO


${cblue}P13: Monitorea tu systema$cend
  TODO

${cblue}P19: Otros$cend

${cblue}End:$cend
  * Tarea: openssl for HTTPS https://serverfault.com/questions/102032/connecting-to-https-with-netcat-nc
  * Idea: Web hosting, servidor web, apagche, nginx, ver capitulo 19

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
