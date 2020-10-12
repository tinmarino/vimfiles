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

${cblue}P00: Generar unos$end
  El nodo ${cblue}/dev/zero$cend genera un flujo de bits seteado a 0.
  Pero no existe el nodo ${cblue}/dev/one$cend que generaria un fujo de 1
  ${cyellow}> cat /dev/zero | tr '\\000' '\\001' | hexdump -C$cend
  El commando (${cyellow}> tr$cend) significa TRanspose, cambia un caracter en otro. Ahi el prefijo \\0 significa lee el caracter siguiente con eondage octal.



${cblue}End:$cend

TODO 5
* Play with urandom and $RANDOM and command interpolation
* Null
* Hacer archicos muy grandes

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
