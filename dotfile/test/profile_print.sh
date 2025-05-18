#!/usr/bin/env bash

if ! (return 0 2>/dev/null); then
  >&2 echo "--> $0 starting with $*!"
  profile_print_main "$@"; res=$?
  >&2 echo "<-- $0 returned with $res!"
  exit "$res"
fi
paste <(
   while read tim ;do
       [ -z "$last" ] && last=${tim//.} && first=${tim//.}
       crt=000000000$((${tim//.}-10#0$last))
       ctot=000000000$((${tim//.}-10#0$first))
       printf "%12.9f %12.9f\n" ${crt:0:${#crt}-9}.${crt:${#crt}-9} \
                                ${ctot:0:${#ctot}-9}.${ctot:${#ctot}-9}
       last=${tim//.}
     done < /tmp/sample.tim
) /tmp/sample.log
