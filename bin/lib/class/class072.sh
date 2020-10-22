#!/usr/bin/env bash
# -- Tarea: wget, curl, nano, emacs
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+===================+
| Heramienta: Tarea |
+===================+$cend


${cblue}P01: Chroot$cend
  En la clase, hemos corrido la version independiente (StandAlone) de BusyBox.
  Pero para correr un programa cualquiera, hay que copiar sus dependencias.
  Aqui vamos a correr BaSh en un enterno con raiz cambiada.
  Nota que la BusyBox tiene \"Sh\" pero no \"BaSh\"

  Uno no quiere corre el programa como root
  > chroot --userspec=tourneboeuf:tourneboeuf

  > cp -v /bin/{bash,touch,ls,rm,cat} $home/chroot_jail
  TODO




${cblue}End:$cend

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
