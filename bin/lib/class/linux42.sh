#!/usr/bin/env bash
# -- Tarea: dd, filefrag, fork, exec
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+==================+
|  Explorar: Tarea |
+==================+$cend

${cblue}P01: Generar unos$end
  El nodo ${cblue}/dev/zero$cend genera un flujo de bits seteado a 0.
  Pero no existe el nodo ${cblue}/dev/one$cend que generaria un fujo de 1
  ${cyellow}> cat /dev/zero | tr '\\\0' '\\\377' | hexdump -C$cend
  El commando (${cyellow}> tr$cend) significa TRanspose, cambia un caracter en otro. Ahi el prefijo \\0 significa lee el caracter siguiente con eondage octal.


${cblue}P02: Instalar un driver$end
  Nos gustaria tener un archivo ${cblue}/dev/one$cend que genera solo unos tal como ${cblue}/dev/zero$cend genera solo zeros.

  Para estar claro:
  ${cyellow}> cat /dev/zero | hexdump -v$cend  # Ctrl-c para acabar
  Genera solo zeros: el numero a la izquierda es offset, la posicion en el archivo.
  Querermos que estos zero sean unos osea F en hexadecimal (que es 1111 en binario)

  Pero ${cblue}/dev/one$cend no existe en el nucleo Linux que es monolitico.
  Se puede instalar pilotos. Pero este no existia, asi que lunes 12 de octubre, lo escribi.

  Ahi esta: https://github.com/tinmarino/dev_one
  Tu mision es instalarlo! Tiempo estimado: 20, 30 minutos.
  Lo interesante es que entiendas la conversacion que sigue, osea donde te metes.

  Un piloto es un programa que vive en el espacio del nucleo, asi que es la mision mas bajo nivel que te tocara. Pero es importante haber metido la manos ahi.

  1/ La diferencia grande entre el espacio usario el espacio nucleo es que en el nucleo, no hay usario! Nadie para decir cuando empezar o acabar un programa. Asi que ${cblue}todo los programa nucleos son servicios$cend (los servicios desafortunamente solo seran visto en la clase 9)
  2/ En el nucleo hay solo un usario: root (la raiz abajo en el nucleo, suena coherente) y tiene acceso a todo tu systema sin que nadie lo pueda vigilar. Asi que si un virus se mete ahi, no lo detectas, ni lo sacas, pero el te espia todo sin que veas ni siquiera que usa el CPU.
     Por lo tanto existe un protecion adicional (en todos los sistema: Windows, Linux, Mac y Android) que obliga los fabricantes. Esta protecion es una firma. Si tu firma tiene autoridad, se instala sencillamente, sin ruido. Si no (como en mi caso), tienes que pedir al usario desabilitar el \"Secure boot\" es su bios o abilitar la firma reiniciando su programa y interactuando a nivel casi electronico: en el UEFI (nuevo BIOS) mas bajo que el hypevisor que es mas bajo que el kernel, lo que un virus no puede hacer ya que no tiene las manos sobre el compu.
  3/ Para finalmente interactuar con el usario final (sino serian inutiles), los pilotos contruyen archivos y leer o escribir en estos archivos dispara las funciones deseadas, aqui escribir 1111111 infinitamente y rapidamente.
"

  # shellcheck disable=SC2016  # Expressions don't expand in single quote
  msg+='
           .-""""-.
          ////||\\\\  Humans, some mammels
          |/      \|  Carbon based and hard to predict
Ring 4   (  @   @   )
          |   C    |
           \  ==  /
            `|--|`
              ^
              |
           +--------------------+ Easy to write and isolate
Ring 3     | Unpriviledged Code | Safe fail
           +--------------------+ Ex: BaSh
              |
           +-----------------+ Hard to isolate
Ring 2     | Priviledge Code | but that can be an advantage
           +-----------------+
              |                          USERLAND
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              |                          KERNELLAND
           +---------------+
Ring 1     | Device Driver | In kernelland, get access to
           +---------------+ the hardware abstracion layer
              |              Can be compiled seprately as module
              |
           +--------------+ Monolyte: /boot/vmlinuz-5.4.0-48-generic
Ring 0     | Linux Kernel | Imposible to isolate, must shutdown to change
           +--------------+
              |                          KERNELLAND
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              |                          UNDERWORLD
              |
           +------------+ CPU new funcionality
Ring -1    | Hypervisor | for enhanced virtualisation
           +------------+
              |
           +------------------------+  UEFI, ex BIOS
Ring -2    | System Management Mode |  (press f2 at boot)
           +------------------------+
              |
              |                          UNDERWORLD
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              |                          E-SPACE (Harware)
              |
           +------------+ Embeded in some
           | Micro Code | micro controlers
           +------------+ = (μCPU, μRAM, μSSD)
              ^
              |
           _______
          | _____ | Cober circuits. Made by computer
          ||_____|| Programmed with lines of code
          |  ___  | In VHDL language
          | |___| |
          |       | Crafted in China or Vietnam
          |       |
          |       |
          |       |
          |       |
          |_______|
'

  msg+="

${cblue}P03: Monitoreo de processos (top)$end
  ${cyellow}> top$cend  # q to exit, enter to refresh faster
  En una terminal:
  [+] Es facil ejecutar, aun a distancia (ssh sin configuracion)
  [-] Es feo y (muy) complicado de usar (con el teclado)

  Tienes una applicacion llamada \"System Monitor\"?


${cblue}P04: Encuentra tus limites (ulimit)$end
  Show me all your limit:
  ${cyellow}ulimit -a$cend  # ulimit = Your Limit, -a = all


${cblue}P05: Explota tus limites (fork bomb)$end
  Prepara tu machina, real y virtual porque vas a tener que reiniciarla.
  Eso se llama un \"fork bomb\".
  Cada vez que corre la function, lanza dos subprocesos en fondo:
  Debido al tubo \"|\" y al fondo \"&\" lanza la funcion como proceso.
  Por lo tanto duplica sus recursos a cada invocacion y eso explota la RAM, hace perder la cabeza al planificador (scheduler). Y va a bloquea tu compu.

  Si no quieres bloquear tu compu, confia en mi y no lo corres
  ${cyellow}> bomb() {
bomb | bomb &
}; bomb$end


${cblue}P06: Limita tus limites y evita la explosion$cend
  ${cyellow}> ulimit -u 5000$cend  # Limita el numero de proceso del shell a 5000
  ${cyellow}> bomb() { bomb | bomb & }; bomb$end  # Ahora si corre la bomba
  Ciera la terminal para matar en cadena esta cadena de procesos

  <= Accuerdate (clase 4) que cerar un shell envia SIGTERM a todo sus hijos, y que el comportamiento por defecto al recebir una senal SIGTERM est terminar.

  Has visto el \"fork bomb\" un tipo de ataque primitivo que provoca una negacion de servicio (Denial Of Service DOS) osea quebra la macina del adversario y has visto como defenderse de este ataque (acuerdate de \"Your limits\")


${cblue}P07: Cuanta memoria libre (free)$cend
  ${cyellow}> free -h$cend
  H como \"human read\" con el Gi. Como \"du -h\".
  Mas detalles:
  ${cyellow}cat /proc/meminfo$cend


${cblue}End:$cend
  Asi acabas la primea mita de la clase intensiva de Linux. Felicitacion!

  Manana: la prueba de mitad de clase.
  Asi que te toca revisar. Puedes usar el commando que definimos en la clase 042:

  ${cyellow}> jim --doc | grep -ao '> \\(sudo \\)\\?\\w\\+' | sed 's/sudo //' | cut -c 3- | sort -u | awk '{print \"apropos -l \\\"^\" \$1 \"\$\\\"\"}' | bash 2>&1 | grep -v \"nothing appropriate\" | tee command_index.txt$cend
  ${cyellow}> xdg-open command_index.txt${cend}

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
