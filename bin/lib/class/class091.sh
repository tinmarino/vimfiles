#!/usr/bin/env bash
# ${cblue}System: Servicio y Servidor$cend:
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+========+
| Servir |
+========+$cend

Un servicio es la operacion de servir. Aqui es un programa que hace una tarea de servicio.
Un servidor es una machina que aloja servicios.

En esta clase, usaste mis servicios (sshd) y los de wikipedia (httpd). Cuando te connectaste como cliente via ssh o http.
Nota que el d significa \"demonio\" en el sentido \"sin dios ni ley\" en el sentido actua solo, sin usario => es un servicio!
Aloja (es decir ejecuta) uno de estos y eres un servidor!

0/ Antes de empezar: que servicios estan corriendo en tu machina ahora?
1/ Primero vamos a correr servicio el mas simple: de los 90 en Python: un servicio de systema de archivos
2/ Despues algo un poco mas potente: de los 2000 en Java: Apache: un proxy de servicio, y el systema cgi que ha sido tan util
-- En este contexto (2000), hablaremos de Php y porque esta mal. Porque Ruby es merjor pero igual esta mal. Porque Python y Java, los mas viejos, todavia la llevan en 2020. Porque Java es mejor que Python. Y nos lleva a 2020:
3/ Pues vamos a ver, en 2020, un servicio completo (que uso), se llama Jenkins, esta en Java pero sin Apache, lo instalaremos.
Tambien hablaremos de ElasticSearch totalmente en Java con Kibana tambien en Java que muestran lo que existe hoy. Vas a aceder al mio porque hay que instalar Apache y es pesado.
4/ Para acabar: vamos a hacer un sitio en internet (con tu CV y 2 paginas, en 20 minutos!)

$cblue
+==========+
| Servidor |
+==========+$cend

En informática, un servidor es una pieza de hardware o software (programa informático) que proporciona funcionalidad para otros programas o dispositivos, llamados clientes. (Wikipedia)

${cblue}P01: Interface a los servicos (service o systemctl):$cend
  ${cyellow}> service$cend  # Aqui listeas los servicios presentes (ejecutandose [+] o no [-])
  Ssh : ya no conoces, permita connectarse con terminales y ejecutar commandos sobre otras machinas
  Cron: para cronological, es un servicio que ejecuta cosas (que tu defines) cada cierto tiempo. Respaldos, Synchronisacion, Compilacion. Es bakan pero hay que \"tener la mano\" sobre el servidor (tu machina) para configurarlo, lo que a veces es overkill (hay que hacer un ssh).
  Httpd: No lo tienes me imagino, prove una interface http, permite connectarse con mozilla firefox, que a veces es mas rapido que con terminal (mas amigable al usario)

  No vamos a ver sshd (que haces su pega solo) ni de cron (que solo ejecuta los archivos en ${cyellow}/etc/cron.hourly$cend) cada hora).
  Vamos a estudiar otros servicios que usan httpd. Los servicios pueden usar servicios. Abusando de eso es recomandado y llega a la architectura de micro servicios. Es mas resiliente ya que evita los puntos unicos de fracaso.

  Aparte:
  ${cyellow}> systemctl -h$cend  # -h = help. Se supone que es mejor que service pero me cuesta usarlo, usamos el coando service no mas
  Fin del Aparte


${cblue}P02: Netcat: Http: Servicio Hello World$cend
  while true; do { echo -e 'HTTP/1.1 200 Hello World\r\n'; sh test; } | nc -l 8081; done

  En Firefox, navega: localhost:8081

  Nota que, desafortunadamente, BaSh no tiene el poder de abrir un socket en escucha.
  En la implementacion de BaSh, se ve que usa solo la llamada systema de interacion con scoket con \"connect\" (cliente) y no \"bind\" servidor
  Fuente: https://unix.stackexchange.com/a/49947/257838


${cblue}P03: Python: Servidor Http basico:$cend
  ${cyellow}> cd$cend  # Sin argumentos, va a casa (obvimente el lugar por defecto, es tu casa)
  ${cyellow}> python3 -m http.server$cend  # Ctrl-c para acabar
  -- Navega los directorios
  -- Abre una pagina html
  -- Admira la semejancia entre el URL (enlnace en firefox) y el camino en el filesytem: y si lo corres con PWD en /?


${cblue}P04: CGI: Common Gateway Interface$cend
  Para crear tu primer servidor CGI, sigue este tutorial:
  https://code-maven.com/set-up-cgi-with-apache


${cblue}P05: Pagina Github$cend
  Esta es la mia: https://tinmarino.github.io/
  Aqui estan los archivos: https://github.com/tinmarino/tinmarino.github.io (esta un poco desordenado <= me da miedo borrar cosas)

  Para hacer el tuyo, lo mismo remplazando tinmarino con tu cyber nombre. No Puede ser Jim, tiene que ser mas largo! Tienes un nombre de hacker? Tienes que encontrarte uno: todos tenemos: SilverFox, DarkPsychoz, Ochod, Milkyway, NanoHate, Tinmarino
  NO: Jsan (tomado)
  NO: JimSan (tomado)
  NO: JackySan (tomado)
  NO: JaiSan (tomado)
  OK: JaimeSan (pero feo)
  OK: JaimeSanhueza (por mientras)

  1/ Create una cuenta github
  2/ Crea un repositiio nombre_de_cuenta.github.io  # Remplaza nombre_de_cuenta por tu nombre de cuenta (usario)
  3/ Sigue lo que dice para tener el repo en tus archivos locales
  4/ Pon una pagina html o tu cv en pdf
  5/ Empuja
  6/ Visita tu pagina y admira como hiciste una pagina permanente en 20 minutos!


${cblue}P06: Route$cend
  Read this: https://www.cyberciti.biz/faq/ip-route-add-network-command-for-linux-explained


${cblue}P07.1: Nginx Instalacion$cend
  Nginx es un servidor web, como Apache.
  Puede ser usado como proxy (alias procurador) inverso.
  Es decir que del mismo puerto (80 => HTTP o 443 => HTTPS) redirige distintas solicitudes a dinstintos servicios.

"
abat << 'EHD'
# Mira que aplicacion que cononce tu cortafuego
sudo ufw app list

# Instala nginx
sudo apt install nginx

# Mira que aplicacion que cononce tu cortafuego ahora
# La magia de la instalacion: Aparece "Nginx HTTP"
sudo ufw app list

# Permite a Nginx de escuchar en el puerto HTTP (el numero 80)
sudo ufw allow 'Nginx HTTP'

# Analisa el estatus del cortafuego
sudo ufw status

# Analisa el estatus de nginx
systemctl status nginx

# Si no esta prendido lee y resuelve los errores
# -- en mi caso, apache2 esta ocupando el puerto 80, lo tuve que parar
# -- lo encontre asi:
netstat -laputn | grep 80
# -- lo mate asi con kill -15, y si no para kill -9

# Asegurate que nginx cumple bien con su funcion:
# -- Que abro el puerto 80 en lectura
netstat -laputn | grep 80
# -- Que entrega bien la pagina
curl -X GET localhost  # En en firefox en la barra de url "localhost"
EHD
  echo -e "


${cblue}P07.2: Nginx primer sitio$cend
  Vamos a servir localmente el sitio jim.com
"
abat << 'EHD'

# Crea el directorio del sitio jim.com
sudo mkdir -p /var/www/jim.com/html

# Cambia el dueno y los permisos para que:
# -- 1/ Lo puedas editar
# -- 2/ Nginx lo pueda servir
sudo chown -R $USER:$USER /var/www/jim.com/html
sudo chmod -R 755 /var/www/jim.com
EHD
  echo -e "

  Crea la pagina de entrada (index.html) del sitio
  Copia la pagina siguiente en /var/www/jim.com/html/index.html
  -->"
abat html << 'EHD'
<html>
  <head>
    <title>Welcome to Jim.com!</title>
  </head>
  <body>
    <h1>Success! The jim.com server block is working!</h1>

    This page is served by Jeimy & Co
  </body>
</html>
EHD
  echo -e "
  <--

  El sitio web esta hecho, hay que explicar a Nginx como servirlo.
  Es mejor separar la configuracion de cada sitio en un archivo independiente
  Copia la configuracion siguiente en /etc/nginx/sites-available/jim.com

  -->
"
abat conf << 'EHD'
server {
  listen 80;
  listen [::]:80;

  root /var/www/jim.com/html;
  index index.html index.htm index.nginx-debian.html;

  server_name jim.com www.jim.com;

  location / {
    try_files $uri $uri/ =404;
  }
}
EHD
  echo -e "
  <--

"
abat << 'EHD'
# Configuraste el sito, habilitalo
sudo ln -s /etc/nginx/sites-available/jim.com /etc/nginx/sites-enabled/

# Quizas tendras que descomentar la linea "server_names_hash_bucket_size 64;" en "/etc/nginx/nginx.conf"

# Mira si la sintaxis de tu configuracion esta buena
sudo nginx -t

# Reinicia Nginx
sudo systemctl restart nginx

EHD
  echo -e "

  Intenta navegar en jim.com. Te redirige a un servidor en internet.


${cblue}P08: Hosts$cend
  Linux esta \"bien\" configurado por defecto.
  Es decir configurado para que un cliente pueda navegar en internet sin tener que configurar su piloto de red, sus ruta, sus huespedes conocidos ...
  Por defecto:
  -- El piloto de red es el que se puede connectar al router
  -- Los rutas son las que te dicen el router
  -- Los huespedes son los que te entrega en DNS que ha elejido el router

  Pero tu no quieres seguir la configuracion del router. Tu estas haciendo un proxy inverso => tu eres el router! Y un router de un servidor, no de un cliente tonto.
  Por lo tanto, vamos a configurar tus huespedes conocidos para que cuando busques la IP de jim.com, la pila de la red te devuelva \"127.0.0.1\" (alias \"localhost\").
  Suena complicado! Porque lo es. EL la pila de la red, lo puedes configurar:
  -- Localmente: al principio de la pedida o cambiado los route, o haciente un servicio DNS en tu compu
  -- En tu router: Devolviendo la solicitud a tu compu
  -- En internet comprando un nombre de dominio (150 dolares al ano en 2020)

  Mejor hacerlo lo antes possible.
  Esta tarea es complicado pero bastante commun para que el nucleo de Linux haga todo por ti => resulta re facil (como Docker)
"
abat << 'EHD'
# Agrega jim.com a tus huespes conocidos
# -- Para que rediriga a tu computador y no al IP
# -- que te entrega el DNS de internet
sudo echo '127.0.0.1 jim.com' > /etc/hosts

# Prueba de nuevo, navega jim.com en Firefox
EHD
  echo -e "


${cblue}P09: Doc: Nginx Archivos importantes$cend
  Ahi esta la clase de Nginx que copie/pegue.
  Tiene un excelente resumen de los archivos de configuracion de Nginx.
  https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04


$cblue
+==========+
| Servicio |
+==========+$cend

Un servicio es un componente que realiza operaciones en segundo plano sin una interfaz de usuario. (Android developers)
Tambien se llaman demonios (daemons) porque corren en el infr mundo y no tienen ni dios ni ley.
En Linux, a veces, su nombre acaba en \"d\". Ejemplo: sshd, httpd, uuidd, osspd. Contra ejemplo: apache, nginx, dovecot


${cblue}P11: Crea tu primer servicio (php)$cend
  Php es un idioma que ha sido creado justamente para hacer servicios (corriendo en CGI para internet).
  Es muy facil desarollar pero es mas lento y inseguro que java. En nuestro caso es bastante pero nota que los servicios serios (ElasticSearch, Jenkins) estan escrito en java.

  Para crear tu primer servicio, seigue este tutorial:
  https://medium.com/@benmorel/creating-a-linux-service-with-systemd-611b5c8b91d6


${cblue}P12: Manipular dynamicamente los servicios$cend
  Juega con el servicio \"rot13\" que recien creaste para aprender los commandos de manipulacion de servicio.
  https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units


${cblue}P13: Monitorea tu systema$cend
  Ejecuta estos commandos uno por uno.
"
abat << 'EHD'
top  # q para salir muestra los processsos que los mas usan recursos.
sudo service --status-all  # lista los servicios
systemctl --type=service --state=active  # Lo mismo
cat /proc/meminfo
EHD
  echo -e "

  Para conocer mas comandos: buscar en internet: \"linux monitor system CLI list\"


${cblue}P14: Interactua Nginx$cend
"
abat << 'EHD'
# To stop your web server, type:
sudo systemctl stop nginx

# To start the web server when it is stopped, type:
sudo systemctl start nginx

# To stop and then start the service again, type:
sudo systemctl restart nginx

# If you are simply making configuration changes, Nginx can often reload without dropping connections. To do this, type:
sudo systemctl reload nginx

# By default, Nginx is configured to start automatically when the server boots. If this is not what you want, you can disable this behavior by typing:
sudo systemctl disable nginx

# To re-enable the service to start up at boot, you can type:
sudo systemctl enable nginx
EHD
  echo -e "


${cblue}End:$cend
  Acabaste esta penultima clase. Felicitacion!

  ${blue}Configuracion (hemos visto):$cend
  Nota que todo pasa por la configuracion ya que los servicios corren sin interacion directa con el usario.
  El dia que tengas que hacer un servidor de correos electronicos, vas a jugar mucho con configuraciones: no codigo imperativo sino declaraciones de configuraciones.
  Este dia, no olvides el ciclo de desarollo de programas porque la declaracion de configuracion es, al final, desarollo informatico.

  ${blue}Pilotos (mas alla):$cend
  Creaste un servicio, es mas complicado que un procesos normal, sobre todo para interactuar con ese.
  Un piloto es un servicio que corre en el nucleo. Asi que crear, cargar, interactuar con servicios es el camino natural para crear pilotos.
  El proceso para isntalar un piloto es exactamente igual (crear, cargar, interactuar).
  La diferencia reside en el codigo ya que el piloto (en el nucleo) no puede usar todo lo que existe en el espacio usario. Ademas, en el nucleo, el error es mas imperdonable. Aunque hoy dia, los modulos nucleo pueden tener errores irecuperables sin provocar un kernel panic.

  Tag: > nginx > ufw > systemctl
  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
