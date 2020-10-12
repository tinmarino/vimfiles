#!/usr/bin/env bash
# ${cblue}Syntax: Monolinea$cend: Recreo
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+===========+
| Monolinea |
+===========+$cend

Un escript Monolinea (One Liner) es un programa que mide una linea.
Tiene ventaje en la portabilidad (facil copiar pegar, buscar en tu historial) y genericidad (no es muy personalisado).
Los commandos Linux responden a la filosofia: \"hacer una cosa y hacerla bien\".
Entonces, para las tareas del cotidiano, estas operaciones atomicas suelen combinarse en tubos, ejecuciones en serie o paralelo en lo que se llama monolineas.

${cblue}End:$cend
  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
