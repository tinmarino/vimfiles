#!/usr/bin/env bash
# ${cblue}Syntax: Language$cend: Funcion, Rama, Ciclo
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  echo -e "$cblue
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
                         



$cblue
+===================+
| Expresión regular |
+===================+$cend

Una expresión regular es una secuencia de caracteres que conforma un patrón de búsqueda.
Es como un sub-idioma.

El idioma consiste en atomos, multiplicadores y alteraciones.
Una buena referencia es:

${cyellow}> man perlreref$cend

No olvides que Perl significa: \"Pattern Extraction and Report Language\".
Y extracion de patrones se hace mediante expreciones regulares.

Muy facil:
  AlphaNum: Los caracterres alpha numericos como 1, 3, s, b significan estos caracteres literales, excepto si estan escapados como, \\1, \\3, \\s, \\b en cual caso, toman un significado especial
  Punctuacion: La punctuacon como: ., ?, (, [, * tiene un significado especial excepto si estan escapado como: \\, \\? ,\\(, \\[ en caul caso, tienen un significado literal


${cblue}P01: Un ejemplo gramatical$cend
  ${cyellow}> grep -P '^(cat|echo) .*\|.*$' abs.txt$cend

  ^  ---------  principio de linea (atomo)
  (  ---------  empezar grupo (token)
    cat  -----  \"cat\" literal (serie de atomos)
    |  -------  o (alteracion)
    echo  ----  \"echo\' literal
  )  ---------  ciera grupo
  <espacio>  -  espacio literal
  .  ---------  cualquier caracter (atomo)
  *  ---------  cualquier numero de veces (quatificador)
  \| ---------   \"|\" literal
  .* ---------  cualquier caracter, cuaquier numero de veces
  $  ---------  fin de linea (atomo)

  Lo que coicide (match) con:
  -- cat o echo al principio de la linea seguido por
  -- un espacio y cualquier numero de cualquier caracteres (\".*\") seguidos por
  -- un tubo \"|\" seguido por cualquier numero de cualquier caracteres (\".*\") seguido por
  -- el fin de la linea

  Puedes ya qdivinar que \".*\" se usa mucho en RegEx


${cblue}P22: Descarga el libro Advanced Bash Scripting$cend
  Ya deberias tenerlo del la clase 6:
  "
  abat <<< '  wget -qO- https://tldp.org/LDP/abs/abs-guide.txt.gz | gunzip - > abs.txt'
  echo -e "


${cblue}P23: Corta el contenido del libro, principio de linea (^)$cend
  Aqui vemos nuestra primera exprecion regular en sed:
  ^Chapter => Match principio de linea (\"^\") seguido por literalmete \"Chapter 2\"
  "
  abat <<< "  cat abs.txt | sed '/^Chapter 3/ q' > ab.txt"
  echo -e "

  Sed hace para cada linea el commando pasado en parametro.
  Aqui el commando es: si la linea coincide con el patron entre \"/\", quit (\"q\")
  

${cblue}P24: Estar o no estar: quantificadores (?)$cend
  Hay distintos dialectos de expreciones regulares.
  Vamos usar las de Perl: PCRE para Perl Compatible Regular Expression
  Por lo tanto, agregaremos la opcion \"-P\" a grep
  Ademas para evitar que el argumento se divide o expande o interpole, lo pondremos entre simples citas

  Queremos encontrar las palabras \"sh\" o \"bash\"
  "
  abat <<< "  grep -Pi 'b?a?sh'"
  echo -e "
   
  -P: Exprecion regular en formato Perl
  -i: Ignore case = pude ser mayuscula o minuscula
  
  El patron es:
  b? = \"b\" o nada (\"?\")
  a? = \"a\" o nada (\"?\")
  sh = \"sh\"

  Mira la parte \"SYNTAX\" (opcinalmente \"QUANTIFERS\") del manual.
  Tienes que entender ?, * y +
  De hecho, vamos a buscar en el manual (o en vim) con \"/\". En nano apreta f1 para obtener ayuda.


${cblue}P25: Regex a atomo: grupar (())$cend
  El problema de la RegEx precedente es que puede coincidir con \"bsh\" o \"ash\".
  Nira que aparece \"f${cred}ash${cend}ion\" y \"Su${cred}bsh${cend}ells\"
  Por eso queremos \"ba\" o nada, es decir tratar \"ba\" como un atomo.
  Eso se llamar grupar (gruping) y se hace mediante parenthesis, como en una ecuacion mathematica.
  "
  abat <<< "  grep -Pi '(ba)?sh'"
  echo -e "

  El patron es:
  (ba)? = \"ba\" o nada
  sh = \"sh\"

  Asi, si queremos coincidir con el SheBang #!/bin/bash
  "
  abat <<< "  abagrep -Pi '#!\/bin\/b?a?sh' ab.txt"
  echo -e "

  Nota solamente que tube que escapar los \"/\" -> \"\\/\" que tienen un significado especial (Principio y fin de regex)


  ${cblue}P26: Alteraciones (|)$cend
  Con multiples grep en un tubo, podemos filtrar exclusivamente, pero como hacemos si quermoes filtrar dos patrones inclusivamente?
  Usamos la alteracion, que es lo utimo de la clase, acuerdate: Atomos, Quantificadores y Alteraciones
  "
abat << 'EHD'
  grep -Pi 'system|programming' ab.txt
  grep -Pi '(system|programming) l' ab.txt
  grep -Pi 'system|programming l' ab.txt
EHD
  echo -e "

  La segunda linea imbrica la ateraciion asi que significa \"system\" o \"programming\" seguido por \"l\"
  Mientras que la tercera significa \"system\" o \"programming l\"


${cblue}P27: Ejemplo$cend
  Un atomo interesante para lo que sigue es \"un digito, es decir entre 0 y 9\".
  Se puede escribir, de la vieja forma como \"[0-9]\" que significa literalemente entre 0 y nueve.
  O con Perl \"\\d\" como Digit, que es mas rapido de escribir
  "
abat << 'EHD'
  grep -Pi '\d*' ab.txt

  # Only match (-o)
  grep -Pi -o '\d*' ab.txt

  # Ordena y cuenta
  grep -Pi -o '\d+' ab.txt | sort -n | uniq -c

  # Nota que el numbero \"36\" aparece mucho, porque
  grep -Pi '36' ab.txt

  # Hum porque es un capitulo que tiene muchas tablas
  # Si queremos saber cual tiene mas tablas
  cat ab.txt | sed -n '/List of/,/A-1./p' | grep -Pi -o '^ *\d+-' | sort -n | uniq -c | sort -n

  # Es el capitulo 16 cierto ?
EHD
  echo -e "




${cblue}P25: $cend


${cblue}End:$cend

  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
