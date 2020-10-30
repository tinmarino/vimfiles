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


${cblue}P01: Clonar un sitio$cend
  TODO find a small website!
  TODO can I cone my github.io?


${cblue}P02: CGI: Common Gateway Interface, BaSh examples$cend
  Desarolla los dos primeros servicios CGI en BaSh de este sitio:
  http://www.yolinux.com/TUTORIALS/BashShellCgi.html

  Llamalos y averigua que funcionen correctamente


${cblue}P04: Pagina Github$cend
  TODO crea tu segunda pagina


$cblue
+==========+
| Servicio |
+==========+$cend

${cblue}P11: Crea un servicio CGI para ver archivod (en BaSh)$cend
  TODO


${cblue}P12: Manipular dynamicamente los servicios$cend
  Juega con el servicio \"rot13\" que recien creaste para aprender los commandos de manipulacion de servicio.
  https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units


${cblue}P13: Monitorea tu systema$cend


${cblue}End:$cend

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
