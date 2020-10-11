#!/usr/bin/env bash
# -- Tarea: dd, filefrag, fork, exec
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+====================+
|  Explore: Homework |
+====================+$cend
${cblue}End:$cend

TODO 5
filefrag and dd
  https://unix.stackexchange.com/questions/161922/view-physical-location-of-a-file-directory-on-a-hard-disk
  https://unix.stackexchange.com/questions/514135/getting-sector-number-from-inode-or-address-space-mapping
PLay with urandom and $RANDOM and command interpolation
  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
