#!/usr/bin/env bash
# -- Tarea: man, apropos, pstree, /dev/random
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+=================+
|  Jobs: Homework |
+=================+$cend
${cblue}P01: Listea y describe los commandos cononcidos$cend
  Me preguntaste: \"Hay un sitio para listas de commandos ?\"
  Y te respondi: \"Mejor vealo en TU sistema y mantenga tus notas tu mismo.\"

  Para resumir los commandos de esta clase, corre este commando:
  ${cyellow}> jim --doc | grep -o '> \\(sudo \\)\\?\\w\\+' | sed 's/sudo //' | cut -c 3- | sort -u | awk '{print \"apropos -l \\\"^\" \$1 \"\$\\\"\"}' | bash 2>&1 | grep -v \"nothing appropriate\"$cend
  Puedes redirecionar el output de este en un archivo para leerlo mas tranquilo

  A ver lo que hace <= es un interesante ejemplo real.
  No copies estos commandos, es solo una descripcion:

  ${cyellow}> jim --doc$cend  # Ese es un commando que el yo hice, que escribe todo el el StdOut
  ${cyellow}> grep -o '> \\(sudo \\)\\?\\w\\+'$cend  # Agara: -o = escribe solo lo que agaro y lo las lineas enteras como el defecto, un character \">\", despues \"sudo \" o no \"\\?\", despues characters de palabra \"\\w\", 1 o mas \"\\+\", ese ultimo argumento es una ${cblue}Exprecion Regular$cend
  ${cyellow}> sed 's/sudo //'$cend  # Remplaza \"sudo \" (sudo y espacio) por nada (en cada linea)
  ${cyellow}> cut -c 3-$cend  # Corta (Cut) los 3 (\"3\") primeros caracteres (\"c\")
  ${cyellow}> sort -u$cend  # Ordena lexicographicamente de forma unica: lo mismo que ${cyellow}sort | uniq$cend pero mas rapido (porque corre un processo y no dos)
  ${cyellow}> awk '{print \"apropos -l \\\"^\" \$1 \"\$\\\"\"}'$cend  # Reordona un poco la impression, poniendo apropos antes que es un commando como man: ver (${cyellow}> apropos hostname$cend)
  ${cyellow}> bash 2>&1$cend  # Pipe to BaSh para ejecutar ${cyellow}apropos$end. Y redireciona la Salida 2 (StdErr) a la 1 (StdOut) porque apropos, aparetemente escribe en el StdErr pero los tubos solo redirectionan el StdOut
  ${cyellow}> grep -v \"nothing appropriate\"$cend  # Agara todas las lineas excepto las que contienen \"nothing appropriate\", porque son lineas donde apropos no encontro nada, porque no eran commandos sino nombre de archivos

  Elegante? O super feo?
  Ambos! Pero ha sido facil de escribir (paso a paso), y hace automagicamente las tareas de extracion y reporte.



${cblue}End:$cend

TODO 4
Subshell
kill like beatch
play with redirection and pipes

  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
