#!/usr/bin/env bash
# ${cblue}System: Heramientas$cend: Docker y Git
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  echo -e "

Hoy vamos a ver una herramientas de Linux útiles para los DevOps (Desarrolladores operacionales) y los administradores de sistema.

Primero vamos a ver los contenedores (ex: Docker): es fácil, solo es poner una caja alrededor de un proceso.

Después vamos a estudiar los controlo dadores de versiones (ex: Git): es difícil, casi una ciencia. Manejan cambios (Guardar, Sincronizar, Mover).


$cblue
+=================+
| Parte 1: Docker |
+=================+$cend

El Sistema de contenerizacion es viejo y sencillo.
Pero vamos a pasar un poco de tiempo sobre ese porque describe bien los recursos que usa un proceso y un proceso es un ladrillo fundamental de u sistema operativo.
Empezamos (1979) limitando el sistema de archivo y acabamos (2013) separando dos núcleos en la misma maquina. Lo mas divertido es que el segundo (2013) es mas fácil que el primero.


${cblue}P01: Chroot, Namespace Jail, Sandbox, Docker, Virtual Machine$cend
  Todo estos mecanismos restringen un proceso:

  ${cyellow}Chroot (1979):$cend Cambia la carpeta raíz, un proceso no puede salir de su carpeta raíz

  ${cyellow}Namespace Jail (2000):$cend Cambia el espacio de nombres (Archivos, procesos, socket). No ha sido muy usado.

  ${cyellow}Sandbox (2010):$cend O Arenero. Este termino genérico se podría referir a todo estos mecanismos.
    Pero se usa hoy (2020) para referirse al mecanismo que usa Firefox para aislar los diferentes sitio web para que una publicidad no pueda espiar tu banco.
    Firefox crea un proceso que pre-carga lo que puede necesitar para interpretar HTML.
    Después esta carga, este proceso se saca permisos de forma permanente. Es decir que ya no podrá cargar ninguna biblioteca (.so en Linux), leer ningún archivo.
    Ahora si, el proceso recibe la pagina web y ejecutara su código JavaScript en un entorno aislado

  ${cyellow}Docker (2013):$cend Comparte el núcleo con el sistema operativo huésped pero nada mas.
    Lo mejor que tiene Docker es que sea fácil de usar, en linea de comando (CLI) y que es mas liviano que una maquina virtual.
    En la nube se usan ambos: Docker en maquinas virtuales

  ${cyellow}Virtual Machine (1966):$cend Simula componentes de una machina (CPU, RAM, HD). En esta machina virtual puede correr otros programas (ex: VirtualBox, Java Virtual Machine).
    No confundir con un interpretador aunque sea parecido, el interpretador lee código tal como el humano lo escribe y la maquina virtual corre código compilado.
    En mejor ejemplo esta en el sistema Android donde un núcleo Linux corre maquinas virtuales Java (JVM por Java Virtual Machine) que corre aplicaciones. Así cada aplicación es separada de forma optima.


${cblue}P02: Cambio de raíz: Chroot$cend
  El comando \"${cyellow}> chroot$cend\" (para CHange ROOT) permite cambiar la raíz (el \"/\" del comando \"${cyellow}> ls /$cend\".
  Con esta tecnología, en 1991, se creo el primer tarro de miel (\"honeypot\") para estudiar los virus. El nombre \"honeypot\" aparecerá muy poco tiempo después, con Internet (1991 también) porque sirve para atraer virus como la miel atrae los gusanos.
  Hoy, en 2020, os tarros de miel, están pasando de moda, porque son trampas demasiado obvias. Ahora hablamos de la \"Tecnología del engaño\" (Software decepcion technology).

  Para este ejemplo mínimo, usaremos un binario sin dependencia, así no buscara otros archivos al correr y no hay que copiar todo un árbol de dependencia.
  Usaremos la ${blue}BusyBox$cend caja del ocupado que contiene la lista de los comandos Unix (ver Wikipedia)
  "
abat << 'EHD'
  # Instala el binario
  sudo apt install busybox-static

  # Averigua que esta bien independiente
  ldd $(which busybox)
  # OUTPUTS: not a dynamic executable
  # Lo que significa que es estatico
  # Nota que (> ldd) significa "List Dynamic Dependencies\"

  # Copia el ejecutable busybox en el direcotrio que vas a usar para chroot
  mkdir ~/Test/Chroot
  cd ~/Test/Chroot
  cp $(which busybox) .

  # Ejecuta "sh" de "busybox" en el entorno con raiz cambiada con el usario "jim"
  PS1='chroot.\h:\w\n$ ' sudo chroot --userspec=jim:jim . ./busybox sh
  # Cambie PS1 (el prompt) para este commando
  # -- porque el que esta configurado en tu maquina se refiere a funciones bash

  # Juega en el entorno chrooteado
  pwd
  PATH=/:$PATH
  busybox
  busybox ls
  busybox echo "A new File Created in Chroot Env" > file_from_chroot.txt
  busybox ls
  busybox cat file_from_chroot.txt

  # Observa las limitaciones del cambio de raiz
  busybox ls -di /    # Mira el numero del inode, si no es 2, estas en un chroot
  busybox ps -al      # No puedes listear ni los procesos del chroot, porque falta /proc
  busybox ip address  # Pero si puedes ver la red real
  busybox whoami      # No puedes saber quien eres
  busybox hostname    # Pero si puedes saber el nombre real de la maquina

  # Sal del entorno chrooteado
  exit

  # Mira que se creo el archivo en el directorio real
  pwd
  ls
  cat file_from_chroot.txt
  busybox ls -di /  # Mira que el numero del inode es 2, lo que te dice que no estas en un entorno chrooteado
EHD
  echo -e "


${cblue}P03: Carcel de espacio de nombres (Namespace Jail)$cend
  Como recién hemos visto, el problema de cambio de raíz es que solo aisla el sistema de archivos.
  Para aumentar el nivel de aislo, Berkley Software Distribution (BSD) ha creado una cárcel de espacio de nombres (Namespace Jail).

  Los espacios de nombres son como prefijos a los nombres.
  En un sistema, pueden aplicarse a:
  1. Sistema de archivos (filesystem). Lo mismo que hace el chroot: remplaza ~/Test/Chroot por /
  2. Identificadores de Procesos (PID),
  3. Identificar de red (network stack usado por los sockets)
  4. Usuarios y grupos (UID y GID)
  5. Nombre del huesped (hostname)
  6. Memoria de acceso aleatorio RAM. Se puede aislar la memoria compartida que usan las comunicaciones ínter procesos.

  La cárcel de espacio de nombres permite aislar todo eso.
  Como te puedes imaginar es complicado (y hoy inútil) de usar => no lo vamos a hacer!


${cblue}P04: Arenero (Sandbox)$cend
  La cárcel es mucho trabajo para digamos una pagina web.
  Para una sola aplicación, existe el Arenero.
  Para usarlo de forma programática, puede ser un poco complicado porque hay que cargar todo los recursos antes de aislarse.
  Pero existe un utilitario para correr en un Shell
  "

abat << 'EHD'
  # Instala firejail
  sudo apt install firejail

  # Corre firejail
  firejail  --whitelist=~/Test/Chroot bash

  # Observa
  pwd
  ls ~
  whoami
  ps -aux
  ip
EHD
  echo -e "


${cblue}P05 Docker: lo nuevo$cend
  Docker ha sido creado en 2013 por dotCloud, Inc.
  Y hoy día es muy popular.
  Su gran ventaja es la facilidad del uso (como lo vamos a ver).
  Un contenedor Docker es mucho mas liviano que una maquina virtual porque comparte el núcleo con el huésped.
  Pero obviamente, no se puede reconfigurar este núcleo dentro de un contenedor Docker


${cblue}P06: Docker: Introducción$cend"
abat << 'EHD'
  # Instala docker
  sudo apt install docker

  # Corre tu primer docker
  docker run hello-world

  # Observa
  docker images

  # Otro
  docker run docker/whalesay cowsay Hello there!
EHD
  echo -e "

${cblue}P07: Docker: primer Dockerfile$cend"
abat << 'EHD'
  # Crea un archivo que describe la configuracion y el contenido del contenedor
  nano Dockerfile
  # Escribe lo siguiente:
  # -->
  # FROM debian:stretch
  #
  # RUN apt-get update && apt-get install -y cowsay fortune
  # <--

  # Genera una "Imagen" docker usando la desciption de este DOckerfile
  docker build -t jim/cowsay-dockerfile .

  # Averigua que la imagen ha sido creada
  docker images

  # Corre la imagen, creando un contenedor que desaparece al salir
  docker run jim/cowsay-dockerfile /usr/games/cowsay "Hi!"
EHD
  echo -e "


${cblue}P08: Docker: Imágenes, Contenedores$cend"
abat << 'EHD'
  # Observa
  docker images
  docker ps -a

   # En otra terminal
  docker run -it --name=jim_cowsay_container jim/cowsay-dockerfile  bash
  # -it para InTeractive
  # Le damos un nombre para connectarse, sino docker le da uno por defecto

  # Observa

  # En otra terminal
  docker exec -it jim_cowsay_container bash

  # Intenta conversar entre las dos terminal
  # Si puede, es un oyo de seguridad?

  # Observa
EHD
  echo -e "


${cblue}P09: Docker: Ciclo de vida$cend
  ${cyellow}> firefox https://medium.com/@BeNitinAgarwal/lifecycle-of-docker-container-d2da9f85959$cend
  pause
  unpause
  start
  stop
  kill
  rm


$cblue
+==============+
| Parte 2: Git |
+==============+$cend

${cblue}P11: Git: y Github$cend
  Git es el controlador de versión.
  Creado en 2005 por Linus Torvalds el creador de Linux para controlar las versiones del código del núcleo de Linux.
  Existen otros controladores de versión: Mercurial, Svn, BitKeeper pero Git la lleva!

  Github es un sitio web: https://github.com
  Ha sido comprado por Microsoft en 2018.
  Los servidores de Github alojan servicios Git, por lo tanto, permite respaldar y compartir código. Es muy conocido en el mundo de fuente abierta, sobre todo por ser uno de los primeros y tener bonita interfase html (GUI)
  Ahora tiene también una interfase CLI que se llama Github CLI.

  Existen otros servidores que alojan servicios Git: Bitbucket es mas barato y con mejor interfase en gestión de boleto => Alma lo usa. Gitlab, que se puede alojar en su propia machina y es el primero que podía alojar código privado de forma gratuita => Lo use par preparar presentaciones con colegas sin que nadie vea lo malo de nuestro flujo de trabajo. SourceForge tiene una interfase mas intuitiva que Github, puede importar proyectos enteros de este ultimo.

  Google y Microsoft alojan su código en Github.

  Usa Firefox para crear una cuenta en https://github.com


${cblue}P12: Git: Primer repo$cend
  -> Crea un repositorio en github.com
  -> Llamalo byte_gui
  Github te muestra una pagina quick setup. Leela!
  Nota que Git (CLI) y Github (GUI) suelen aconsejarte en función del momento en que estas.
  Si no has leído estos consejos 10 veces, es bueno seguir leyéndolos.

  En este caso, vamos a seguir: \"create a new repository on the command line\" ...
  -- Porque todavía no tenemos ningún proyecto local.
  -- En ~/Software/ByteGui



${cblue}P13: Git: Ciclo de vida$cend"
abat << 'EHD'
  # 1/ Descarga la siguiente hoja de trucos Git
  wget https://www.jrebel.com/system/files/git-cheat-sheet.pdf

  # 2/ Abrela
  xdg-open git-cheat-sheet.pdf

  # 3/ Y markdown
  firefox https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet
EHD
  echo -e "
  Hablemos de:
  1/ Add, Commit
  2/ Push
  3/ Pull
  4/ Markdown format: tu primer idioma de Markup


${cblue}P14: Git: Primer Push, un poco de Markdown$cend"
abat << 'EHD'
  # 3/ Mueve el escript de la clase anterio en tu proyecto git
  cd ~/Software/ByteGui    # Para trabajaar con git, necesitas tener en working directory en el repo
                           # Suena logico, tienes que estar en el repo para que tus commandos afecten este repo
  mv ~/Test/zik.sh .       # "." significa "aqui" (en el PWD)

  # 4/ Escribe un poco el README.md
  # -- Nota que pongo emfafis en la documentacion,
  # -- que debes escribir y compartir antes que el codigo
  # -- Eso permite ordenar y syncronisar las ideas
  # -- Ver cyclo de desarollo de programa => no precipitarse en el codigo
  nano README.md  # Nota la extencion md para markdown

  # -- agrega el titulo "# ByteGui: CLI para leer ByteBeat"
  # -- (Nota que empieza con "#" un titulo segun el formato markdown)

  # -- Agrega las caracteristicas del proyecto ("features")
  # -- corre "jim class062 head -n 50" y escribes, en ingles los requerimientos como una lista:
  # -- 1. req1
  # -- 2. req 2 (Nota que las lineas empiezan con "1. " que es lista numerotada)

  # -- Agrega los enlaces (despues de un subtitulo "## Links") que encontraras en:
  cat $(which jim)/lib/class/README.md

  # 5/ Agrega las modificaciones de los archivos al "Stagin area"
  # -- Es decir lo que se va a guardar al proximo commit (=instantaneo)
  git add .

  # 6/ Haga la captura instantanea
  git commit -m "Add zik.sh and README.md"  # Lo que esta en doble cita es el mensaje del instantaneo (que ahora llamaremos "commit")

  # 7/ Empuja tus cambios al servidor
  git push

  # 8/ Verifica en tu pagina si los cambios son visibles
EHD
  echo -e "


${cblue}P15: Git: Ramas (Branch)$cend
  Queremos jugar sin contaminar el código de los demás
"
abat << 'EHD'
  # Crear una rama, lamada \"dev\"
  cd ~/Software/ByteGui
  git branch dev

  # Cambiar de rama
  git checkout dev

  # Commitear cambios
  cat 'Git is awesome' > file_to_delete.txt
  git add . && git commit -m 'First dev uselesss commit'

  # Observar
  gitk
EHD
  echo -e "

  Porque las Ramas? Es solo para \"jugar\" es decir hacer pruebas?
  Es realidad las ramas permiten trabajar de su lado, haciendo cambios útiles para el futuro pero que todavía no importan a los femas.
  Cuando la rama personal esta lista, se puede unir a la común.
  Asimismo, se dibujo una hierarquía en unos proyectos: Rama mía < rama comunal < rama regional < rama nacional < rama internacional


${cblue}P16: Git: Introspección$cend
"
abat << 'EHD'
  # Clonea un repositorio (= descargar por primera vez)
  cd Test
  git clone https://github.com/vimwiki/vimwiki Vimwiki; cd Vimwiki

  # Muestra como estamo
  git status

  # Interfase graphica
  gitk --all

  # Muestra las differencias entre el working direcotry Vs Staging area
  echo "This file have been modified" >> README.md
  git diff

  # Remueve las modificaciones
  # git checkout -- README.md  # Eso uso pero te la remove sin devolucion

  # Remueve las modificaciones (con respaldo)
  git stash && git stash pop

  # Mira quien introdujo tal linea => quien tiene la culpa
  git blame README.md
EHD
  echo -e "


${cblue}P17: Git: Unir y rebasar (Merge y Rebase)$cend
"
abat << 'EHD'
  cd ~/Software/ByteGui

  # Crea la rama dev1 y anda ahi
  git checkout -b dev1

  # Haga cambio en common.txt (probablemente nuevo)
  echo some changes in dev1 >> common.txt
  git add . && git commit 'Changes in dev1'

  # Crea la rama dev2 y anda ahi
  git checkout -b dev2

  # Haga cambio en common.txt (probablemente nuevo)
  echo some changes in dev2 >> common.txt
  git add . && git commit 'Changes in dev2'

  # Hagale un repaldo
  git branch dev2_bck

  # Une dev1
  git merge dev1

  # Sigue las instrucitones de git para resolver los conflictos editando archivos
EHD
  echo -e "

  Este ejercicio se puede hacer:
    1. Usando rebase mientras que merge
    2. Haciendo múltiples commits
    3. Editando distintos archivos (Pero si no hay conflicto, es fácil)


${cblue}P18: Git: Remover cambios$cend
  El (sub)comando \"${cyellow}> rebase -i$cend\" permite reescribir la historia.
  Aquí, vamos solo a borrar las ramas que no nos importan.
"
abat << 'EHD'
  # Anda a la rama maestra
  git checkout master

  # Muestra las ramas
  git branch

  # Bora las ramas malas
  git branch -D dev1
EHD
  echo -e "

  Nota que una vez hecho un commit en git, aunque lo borres queda un copia local durante unos meses así que sin miedo.
  Eso si el ${cyellow}> git checkout -- .$cend  o el ${cyellow}> git clean$cend borran todo los cambios locales sin commitearlos.
  Por lo tanto se pierden hasta siempre.


${cblue}P19: Git: Mantenimiento avanzado$cend
  Jugamos en un proyecto real que mantengo Vimwiki
  Donde arregle código bueno pero git malo de un contribuidor.
  Vamos a repetir estos paso codo a codo, te tinca?

  https://github.com/vimwiki/vimwiki/pulls?q=jeromg+type%3Apr


${cblue}End:$cend
  Felicitacion, son dos piedras mas en tu bolisilo, no olvides celebrar cada victoria.

  Hemos visto:
  ${cyellow}> chroot$cend: Commando unix para cambiar el directorio raiz, y asi aislar
  ${cyellow}> docker$cend: El programa de contenedores
  ${cyellow}> git$cend: El programa de gestion de version

  Tags: > nano
  "

}

get_fct_dic
call_fct_arg "$@"
