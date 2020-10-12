#!/usr/bin/env bash
# ${cblue}System: Servicio y Servidor$cend:
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+==========+
| Servidor |
+==========+$cend

La diferencia entre un Servicio y un servidor es obvio.
Un servicio es la operacion de servir. Aqui es un programa que hace una tarea de servicio.
Un servidor es una machina que aloja servicios.

En esta clase, usaste mis servicios (sshd) y los de wikipedia (httpd). Cuando te connecatste como cliente via ssh o http.
Nota que el d significa \"demonio\" en el sentido \"sin dios ni ley\" en el sentido actua solo, sin usario => es un servicio!
Aloja (es decir ejecuta) uno de estos y eres un servidor!

0/ Antes de empezar: que servicios estan corriendo en tu machina ahora?
1/ Primero vamos a correr servicio el mas simple: de los 90 en Python: un servicio de systema de archivos
2/ Despues algo un poco mas potente: de los 2000 en Java: Apache: un proxy de servicio, y el systema cgi que ha sido tan util
-- En este contexto (2000), hablaremos de Php y porque esta mal. Porque Ruby es merjor pero igual esta mal. Porque Python y Java, los mas viejos, todavia la llevan en 2020. Porque Java es mejor que Python. Y nos lleva a 2020:
3/ Pues vamos a ver, en 2020, un servicio completo (que uso), se llama Jenkins, esta en Java pero sin Apache, lo instalaremos.
Tambien hablaremos de ElasticSearch totalmente en Java con Kibana tambien en Java que muestran lo que existe hoy. Vas a aceder al mio porque hay que instalar Apache y es pesado.
4/ Para acabar: vamos a hacer un sitio en internet (con tu CV y 2 paginas, en 20 minutos!)

Y todo eso en 1h, si si! En 1990, lo hariamos en 5h.


${cblue}P00: Interface a los servicos (service):$cend
  ${cyellow}> service$cend  # Aqui listeas los servicios presentes (ejecutandose [+] o no [-])
  Ssh : ya no conoces, permita connectarse con terminales y ejecutar commandos sobre otras machinas
  Cron: para cronological, es un servicio que ejecuta cosas (que tu defines) cada cierto tiempo. Respaldos, Synchronisacion, Compilacion. Es bakan pero hay que \"tener la mano\" sobre el servidor (tu machina) para configurarlo, lo que a veces es overkill (hay que hacer un ssh).
  Httpd: No lo tienes me imagino, prove una interface http, permite connectarse con mozilla firefox, que a veces es mas rapido que con terminal (mas amigable al usario)

  No vamos a ver sshd (que haces su pega solo) ni de cron (que solo ejecuta los archivos en ${cyellow}/etc/cron.hourly$cend) cada hora).
  Vamos a estudiar otros servicios que usan httpd. Los servicios pueden usar servicios. Abusando de eso es recomandado y llega a la architectura de micro servicios. Es mas resiliente ya que evita los puntos unicos de fracaso.

  Aparte:
  ${cyellow}> systemctl -h$cend  # -h = help. Se supone que es mejor que service pero me cuesta usarlo, usamos el coando service no mas
  Fin del Aparte


${cblue}P01: Python: Servidor Http basico:$cend
  ${cyellow}> cd$cend  # Sin argumentos, va a casa (obvimente el lugar por defecto, es tu casa)
  ${cyellow}> python3 -m http.server$cend  # Ctrl-c para acabar
  -- Navega los directorios
  -- Abre una pagina html
  -- Admira la semejancia entre el URL (enlnace en firefox) y el camino en el filesytem: y si lo corres con PWD en /?


${cblue}P02: CGI: Common Gateway Interface$cend


${cblue}P03: Jenkins, caso real$cend


${cblue}P04: Pagina Github$cend
  Esta es la mia: https://tinmarino.github.io/
  Aqui estan los archivos: https://github.com/tinmarino/tinmarino.github.io (esta un poco desordenado <= me da miedo borrar cosas)

  Para hacer el tuyo, lo mismo remplazando tinmarino con tu cyber nombre. No Puede ser Jim, tiene que ser mas largo! Tienes un nombre de hacker? Tienes que encontrarte uno: todos tenemos: SilverFox, DarkPsychoz, Ochod, Milkyway, NanoHate, Tinmarino
  NO: Jsan (tomado)
  NO: JimSan (tomado)
  NO: JackySan (tomado) 
  NO: JaiSan (tomado)
  OK: JaimeSan (pero feo)
  OK: JaimeSanhueza (por mientras)

  1/ Create una cuent github
  2/ Crea un repositiio nombre_de_cuenta.github.io
  3/ SIgue lo que dice para tener el repo en tus archivos locales
  4/ Pon una pagina html o tu cv en pdf
  5/ Empuja
  6/ Visita tu pagina y admira como hiciste una pagina permanente en 20 minutos!





${cblue}End:$cend


  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
