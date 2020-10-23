#!/usr/bin/env bash
# -- Tarea: Language, flujo de control y Regex
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  echo -e"$cblue
+=========================+
| Flujo de control: Tarea |
+=========================+$cend

BaSh no es el language el mas facil, pero si el mas accessible, rapido de llamar yq que es el language por defecto del shell Linux.



$cblue
+==============+
| Regex: Tarea |
+==============+$cend


${cblue}End:$cend

TODO:

en utilisant grep afficher les lignes de /etc/passwd qui se termine par « sync »
grep 'sync$' /etc/passwd



chercher tous les motifs se composant de deux caractères qui se termine par « y » dans /etc/passwd
afficher toutes les lignes de /etc/passwd contenant root,bin ou sync


quel est le résultat de la commande suivante :egrep 'no(b|n)' /etc/passwd,quel est l'effet d'utiliser les parenthèses dans cette expression régulière

chercher dans les 6 premières lignes de /etc/passwd les lignes contenant un caractères numérique

exécuter la commande suivante :grep -E '[0-9]{3}' /etc/passwd,quel est son résultat

à présent on va utiliser la commande wc pour afficher des statistiques concernant le résultat de la commande ls -l /etc

    afficher le nombre de répertoires qu contient /etc

    afficher le nombre de fichier normaux que contient /etc

    afficher le nombre de lien symbolique que contient /etc

    afficher le nombre de fichiers qui ont plus qu'un lien
indication :utiliser grep,cut et wc



https://code-maven.com/slides/perl/exercise-regular-expressions
    has a 'q'
    starts with a 'q'
    has 'th'
    has an 'q' or a 'Q'
    has a '*' in it
    starts with an 'q' or an 'Q'
    has both 'a' and 'e' in it
    has an 'a' and somewhere later an 'e'
    does not have an 'a'
    does not have an 'a' nor 'e'
    has an 'a' but not 'e'
    has at least 2 consecutive vowels (a,e,i,o,u) like in the word "bear"
    has at least 3 vowels
    has at least 6 characters
    has at exactly 6 characters
    all the words with either 'Bar' or 'Baz' in them
    all the rows with either 'apple pie' or 'banana pie' in them
    for each row print if it was apple or banana pie?
    Bonus: Print if the same word appears twice in the same line
    Bonus: has a double character (e.g. 'oo')
  pequeniso programas que se pueden leer o poner en tubos para compilar y ejecutar: Sin color si en tubo
  "

  echo -e "$msg"
}


get_fct_dic
call_fct_arg "$@"
