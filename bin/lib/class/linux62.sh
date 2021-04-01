#!/usr/bin/env bash
# -- Tarea: Heramientas: wget, curl, chroot, docker, git
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../shellutil.sh"

__usage(){
  local msg="$cblue
+===================+
| Heramienta: Tarea |
+===================+$cend


${cblue}P01: Chroot$cend
  En la clase, hemos corrido la versión independiente (StandAlone) de BusyBox.
  Pero para correr un programa cualquiera, hay que copiar sus dependencias.
  Aquí vamos a correr BaSh en un entorno con raíz cambiada.
  Nota que la BusyBox tiene \"Sh\" pero no \"BaSh\"

  Vamos a corre bash en el entorno chrooteado:
"
abat << 'EHD'
  # Define una variable para ayudar
  chr=~/Test/Chroot

  # Cambia el repertorio corriente
  cd $chr

  # Copia los ejecutable que queremos (-v = verbose)
  cp -v /bin/{bash,touch,ls,rm,cat} $chr

  # Muestra las dependencias dynamicas de bash
  ldd $(which bash)

  # Pon la lista de archivos de dependecias en una variables
  lib="$(ldd $(which bash) | egrep -o '/lib.*\.[0-9]')"

  # A ver ...
  echo $lib

  # Copia las dependenciaso
  # -- adminra el --parents que copia los direcotios padres al mismo tiempo
  for i in $lib; do cp -v --parents "$i" "${chr}"; done

  # De la misma forma, copia las dependencias dynamicas de:
  # -- touch, ls, rm, cat
  # -- Es decir remplazar /bin/bash en la definicino de lib por los siguiente
  # -- y repite el comando que copia en un ciclo

  # Entra el el chroot
  # -- El comando es largo porque cambia:
  # -- -- PS1 (el prompt)
  # -- -- PATH (la lista de camino donde BaSh busca los ejecutables)
  # -- -- El usario
  PS1='chroot.\h:\w\n$ ' sudo chroot --userspec=jim:jim  . ./bash -i -c 'export PATH+=/:; export PS1; exec $BASH'

  # Juega
  help  # Comando interno a BaSh ("Builtin")
  ls
  ls -di /
  echo 'In new file' > new_file.txt
  ls
  exit
  ls
EHD
  echo -e "


${cblue}P02: Unshare$cend
  Es una llamada sistema con un comando del mismo nombre.
  Muy nuevo (2013) y desconocido, sirve para aislar un espacio de nombre (i.e. crear un arenero).
"
abat << 'EHD'
  # Aisla el espacio de nombre de los procesos
  sudo unshare --fork --pid --mount-proc

  # Averigua
  ps -aux

  # Sal
  exit
EHD
  echo -e "


${cblue}P03: Wget$cend
  Hablando de herramientas:
  Wget sirve para descarga paginas o sitio del www.
  Los ejercicios que siguen quizás se demoran un poco y chupan mucha conmoción => no dudes en Ctrl-C después de la segunda pagina descargada.

"
abat << 'EHD'
  # Technica para pner comentarios sobre os argumentos
  # -- Define el commando como una cuadra
  cmd=(wget
    # Indica el nombre de la salida con -o (-O para mas mesajes)
    -O taglist.zip
    # Limita el ancho de bando
    --limit-rate=200k
    # Reinicia si la ultima descarga no ha sido completa
    -c
    # Re-intenta 75 veces si falla
    --tries=75
    # Selectiona user-agent (la identidad del navegador)
    # -- nota las citas simples o La evaluacion separara lo que sigue
    # -- en distintos argumentos (word splitting)
    '--user-agent="Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092416 Firefox/3.0.3"'
     # URL de la pagina: por fin
     http://www.vim.org/scripts/download_script.php?src_id=7701
  )

  # Ejectua el commando <= Array interpolation
  # -- <= me demore 10 anios para ya no asustarme de las cuadras en BaSh
  "${cmd[$@]}"
  ls

  # Descarga todo lo que encuentra con ese URL en prefijo
  # -- El problema es que suele no encontrar mucho (ver despues)
  wget --recursive -c -N  --no-parent -nH  -P BashWiki https://wiki.bash-hackers.org/syntax/
  # Ctrl_c rapdio
  find BashWiki

  # Descarga todo esta pagina y los enlaces de esta pagina
  # -- con un limite de recursion de 2
  # -- aun asi, suele descargar todo internet
  # -- por lo tanto, lo limite al dominio que apunto
  wget --recursive  --domains=wiki.bash-hackers.org -P BashWiki -H -l 2 https://wiki.bash-hackers.org/syntax/basicgrammar
  # Ctrl_c rapdio
  find BashWiki

  # Descarga un sitio completo
  # -- El comando precendente, finalmente iba a descargar todo el sitio
  # -- Lo que se hace asi:
  wget --mirror -p --convert-links -P BashWiki https://wiki.bash-hackers.org/
  # Ctrl_c rapdio
  find BashWiki
EHD
  echo -e "

  Anota también las opciones:
  -i list.txt = Descarga desde la lista presente en el archivo list.txt
  -e robots=off = ignora robots.txt, un archivo que ayuda los robots como wget
  --no-check-certificate --content-disposition = no se pero permite descargar de github

  Para saber mas, StackOverflow es tu amigo.


${cblue}P04: Curl$cend
  Curl, es la herramienta para hacer solicitudes HyperText Transfer Protocol (HTTP).
  Por defecto, Curl manda la solicitud POST. Pero existe otras.
  Aquí los distintos métodos HTTP copiados desde \"Mozilla Developer Center\" la referencia sobre las tecnologías de Internet: https://developer.mozilla.org/es/docs/Web/HTTP/Methods

"
abat << 'EHD'
  |-----------+-------------------------------------------------------------------|
  | Solicitud | Descripcion                                                       |
  |-----------+-------------------------------------------------------------------|
  | GET       | El método GET solicita una representación de un                   |
  |           | recurso específico. Las peticiones que usan el método             |
  |           | GET sólo deben recuperar datos.                                   |
  |-----------+-------------------------------------------------------------------|
  | HEAD      | El método HEAD pide una respuesta idéntica a la de una            |
  |           | petición GET, pero sin el cuerpo de la respuesta.                 |
  |-----------+-------------------------------------------------------------------|
  | POST      | El método POST se utiliza para enviar una entidad a un recurso    |
  |           | en específico, causando a menudo un cambio en el estado o efectos |
  |           | secundarios en el servidor.                                       |
  |-----------+-------------------------------------------------------------------|
  | PUT       | El modo PUT reemplaza todas las representaciones actuales         |
  |           | del recurso de destino con la carga útil de la petición.          |
  |-----------+-------------------------------------------------------------------|
  | DELETE    | El método DELETE borra un recurso en específico.                  |
  |-----------+-------------------------------------------------------------------|
  | CONNECT   | El método CONNECT establece un túnel hacia el servidor            |
  |           | identificado por el recurso.                                      |
  |-----------+-------------------------------------------------------------------|
  | OPTIONS   | El método OPTIONS es utilizado para describir las opciones        |
  |           | de comunicación para el recurso de destino.                       |
  |-----------+-------------------------------------------------------------------|
  | TRACE     | El método TRACE  realiza una prueba de bucle de retorno de        |
  |           | mensaje a lo largo de la ruta al recurso de destino.              |
  |-----------+-------------------------------------------------------------------|
  | PATCH     | El método PATCH  es utilizado para aplicar modificaciones         |
  |           | parciales a un recurso.                                           |
  |-----------+-------------------------------------------------------------------|


  # Obtener una pagina web (Aqui la meteo de tu lugar y la ayuda de esta REST API)
  # -- GET: como (yo) obtener esta pagina: Osea (tu) dame esta pagina
  # -- Nota que los metodos HTTP toma el que los manda como subjecto
  curl http://www.wttr.in?n
  curl http://www.wttr.in/:help

  # Hacer multiples solicitudes de una (-s)
  curl -s 'wttr.in/{Santiago,Rancagua,Paris,Cherbourg}?format=3'

  # Especificar tus credenciales
  curl -u username:password -d status='curl is great' http://twitter.com/statuses/update.xml

  # Elejir el protocolo IP (IPv4 o IPv6): Obtener tu IPv4
  curl -4 icanhazip.com  

  # Para seguir, necesitamos un servicio: no encontre en la red uno que hacia solo un log de
  # -- las solicitudes. Instala netcat, el cuchillio Suisso de la red
  # -- (no confundir con netstat que es mucho mas basico)
  sudo apt install netcat

  # En otra terminal (El servidor)
  # Escucha (-l listen) el puerto (-p port) 8080
  # -- y quedate vivo aun al fin de la connection (-k keep-alive)
  nc -l -p 8080 -k

  # NetCat Aprueba !
  # Ahora si !
  # En otro terminal, manda los commandos que siguen

  # PUT: Manda datos
  # -- Mira lo que recibe el servicio
  # -X : --request
  # -m : --max-time (no esperar la repuesta, por defecto hay que apretar Ctrl-C para acabar)
  # -d : --datos
  curl -X PUT -m 0.1 -d arg=val -d arg2=val2 localhost:8080

  # PUT: en formato Json
  # -- Json es mas facil generar, ya que acepta datos con nevo linea, espacio ...
  # -- Es el formato de dato de internet <= (JavaScript Object Notation)
  # -H : --header
  curl -X PUT -m 0.1 -H "Content-Type: application/json" -d '{"name":"mkyong","email":"abc@gmail.com"}'

  # POST: Quasi Lo mismo
  # -- PUT es "idempotent: es decir que hacer 2 veces PUT es como hacerlo 1 vez
  # -- POST no lo es, puedes mandar 2 correos, iguales va a recibir 2 (el medio spam)
  # -- Eso dichos, HTTP no tiene nada que ver con os email que usan los protocolos:
  # -- IMAP, POP3, SMTP (muy complicado, afuera del rango de esta clase)
  curl -d "param1=value1&param2=value2" -X POST localhost:8080

  # POST: un archivo
  # -- 1/ Escribelo
  echo "Si estamos en HTTPS (y no HTTP), solo tu (servidor) y yo (cliente) podemos leer eso" > data.txt
  # -- 2/ Mandalo
  # -- -- @ : Leer at
  curl -X POST -d "@data.txt" localhost:8080
EHD
  echo -e "
  Ese ultimo se lee:
  En HTTP (curl), con el protocolo (-X) \"POST\" manda los datos (-d) en el archivo (@) "data.txt" al servicio
  -- escuchando en el puerto 8080 de este computador \"localhost\" (para huésped local)
  Expresivo ! O no ?


${cblue}P05: Docker$cend
  Ese: https://docs.docker.com/get-started/
  Es la documentación oficial de Docker como lo puedes ver al URL (Universal Resource Locator) (alias: Enlace)
  Sigue la 3 partes de \"QuickStart\"


${cblue}P06: Git$cend
  Ese: https://learngitbranching.js.org/
  Es uno de los 42.000 recursos para aprender Git.
  Este es totalmente el linea.
  Haga los 4 primeros ejercicios (Ramping Up)


${cblue}End:$cend
  Felicitación
  Esa era la clase la mas pesada: herramientas complicadas.
  Y, por primera vez, trabajaste en autonomía.

  Eres listo para ir solo por las calles! Todavía no!
  Osea si pero, un poco de teoría te reforzara => me gustaría retenerte para las 3 mejores clases:
  8. Programación genérica
  9. Servicios y Servidores
  10. Zoologico de los idioma de programacion

  Tag: > nc > netcat
  "
}


get_fct_dic
call_fct_arg "$@"
