#!/usr/bin/env bash
# ${cblue}Link$cend: Recursos para ir mas lejos
#

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

declare -A array=(
  [https://linuxjourney.com/]="${cblue}Lee$cend los secretos del ${cblue}Ninja Linux$cend gratis\n-- Paginas para leer tranquilo en la cama. Completo"
  [http://web.mit.edu/mprat/Public/web/Terminus/Web/main.html]="${cblue}Juega$cend en el navegador y muevete en linea de commando"
  [https://github.com/jlevy/the-art-of-command-line]="${cblue}Lee$cend el arte de la linea de commando"
  [https://devconnected.com/30-linux-processes-exercises-for-sysadmins/]="${cblue}Question$cend 30 for sys admin"
  [https://www.educative.io/blog/bash-shell-command-cheat-sheet]="${cblue}Review$cend 25 commands"
  [https://dev.to/awwsmm/101-bash-commands-and-tips-for-beginners-to-experts-30je]="${cblue}Review$cend 101 commands"
  [https://unix.stackexchange.com/questions/6332/what-causes-various-signals-to-be-sent]="${cblue}Read$cend under which circumstances signals are sent"
  [https://phoenixnap.com/kb/linux-commands-cheat-sheet]="${cblue}Cheat:$cend un ejemplo de cheatsheet, mejor buscar hacer la tuya"
  [https://github.com/LeCoupa/awesome-cheatsheets/blob/master/languages/bash.sh]="${cblue}Cheat:$cend Bien popular, tiene para cada idioma"

  [https://www.howtogeek.com/657780/how-to-use-the-traceroute-command-on-linux/]="${cblue}Read:$cend Clase 3: traceroute"
  [https://resources.infosecinstitute.com/dns-hacking/]="${cblue}Read:$cend Clase 3: DNS hacking"
  [https://linuxize.com/post/how-to-create-users-in-linux-using-the-useradd-command/]="${cblue}Read:$cend Clase 4: useradd"
  [https://www.neoguias.com/crear-usuario-linux-comando-useradd/]="${cblue}Read:$cend Clase 4: useradd tarea"
)

__usage(){
  for i in "${!array[@]}"
  do
    echo -e "${array[$i]}:"
    echo -e "        $i"
  done
}

get_fct_dic
call_fct_arg "$@"
