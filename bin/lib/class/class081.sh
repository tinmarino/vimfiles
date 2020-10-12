#!/usr/bin/env bash
# ${cblue}Syntax: Language$cend: Funcion, Rama, Ciclo
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+==========+
| Language |
+==========+$cend

Escribir languages informaticos es el trabajo de los desarolladores.
No es (para nada) la parte mas dificil de la informatica. Al contrario.
Es el principio. Empezaste tu estudios con eso y yo tambien.
Tal como un ninio empieza su vida intelectual aprendiendo a hablar pero al crecer, puede estudiar litteratura hasta los 80 anios (y mas).
En todo caso, si no sabe hablar, esta cagado!

Un idioma informatico es muy basico. Tiene 50 palabras en 5..10 grupos lexicales (nombre, verbo, adjectivo) distintos. Aqui son: commando, argumento, variable, controlador, commentario, operador.


${cblue}P01: Un ejemplo gramatical$cend
  > if [[ 1 == 1 ]]; then let a=42; else let a=31; fi; echo $a  # Que pasa
    ^- controlador         ^- comando         ^- variable       ^- comentario
            ^- operador                           argumento -^
                         
                             

${cblue}End:$cend

  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
