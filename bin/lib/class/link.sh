#!/usr/bin/env bash
# ${cblue}Link$cend: Recursos para ir mas lejos
#

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

declare -A array=(
  [https://linuxjourney.com/]="${cblue}Lee$cend los secretos del ${cblue}Ninja Linux$cend gratis\n-- Paginas para leer tranquilo en la cama. Completo"
  [http://web.mit.edu/mprat/Public/web/Terminus/Web/main.html]="${cblue}Juega$cend en el navegador y muevete en linea de commando"
  [https://github.com/jlevy/the-art-of-command-line]="${cblue}Lee$cend el arte de la linea de commando"
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
