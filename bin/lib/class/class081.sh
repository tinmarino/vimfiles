#!/usr/bin/env bash
# ${cblue}Syntax: Language$cend: Funcion, Rama, Ciclo y Regex
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


${cblue}P02: Cyclo$cend
  Hay distintas formas de hacer un cyclo, iterar sobre una lista o repetir una tarea cambiando un contador hasta que una cierta condicion ya no sea valida.
  Empezamos con la lista. La generamos con interpolation de rango \"{1..10}\"
"
abat << 'EHD'
  # Experimenta la expancion de rango
  echo {1..10}

  # Tu primer cyclo
  for i in {1..10}; do
    echo "La variable llamada \"i\" tiene el valor $i"
  done

  # Lo mismo en una linea
  for i in {1..10}; do echo $i; done
EHD
  echo -e "

  Bastante facil no?
  El mismo cyclo con sytaxis typo C
  Observa las dobles parenthesis que hacen pensar en una interpolacion arithmetica
"
abat << 'EHD'
  for ((i=1; i<=10; i=i+1)); do
    echo "i = $i";
  done
EHD
  echo -e "

  El mismo cyclo con el cyclo \"Mientras\"
"
abat << 'EHD'
  i=1
  while ((i<=10)); do
    echo "i = $i"
    ((i++))
  done
EHD
  echo -e "

  Un poco sobre el valor de retorno de las operaciones:
  Nota que \$? es una variable que tiene el valor de retorno del commando anterior
"
abat << 'EHD'
  cat this_will_fails_because_file_do_not_exists; echo $?

  echo "this will succeed"; echo $?

  true; echo $?

  false; echo $?

  # Cyclo infinito
  while true; do
    echo "Stop me with a signal (Ctrl-C)"
  done

  # Cabros esto no prendió
  echo "Antes del cyclo"
  while false; do
    echo "En el cyclo"
  done
  echo "Despues del cyclo"
EHD
  echo -e "


${cblue}P03: Condicion$cend
  Cuando un quiere ejecutar codigo solo en ciertos casos.
  La forma canonica es ejecutar un blocke si un commando tiene exito

"
abat << 'EHD'
  # Crea el archivo "present.txt"
  touch present.txt

  # Prueba el sabor del exito
  cat present.txt > /dev/null; echo $?

  # Prueba el sabor del fracaso
  cat not_present.txt > /dev/null; echo $?

  # Pero que aburido esta linea del StdErr, redirigala al StdOut
  # -- que el mismo esta redirigido al agujero negero
  cat not_present.txt > /dev/null 2&>1; echo $?

  # Ahora si podemos probar si un archivo existe => if; then; fi
  if cat present.txt > /dev/null 2&>1; then
    echo "File is present"
  fi

  # Y sino => if; then; else; fi
  if cat not_present.txt > /dev/null 2&>1; then
    echo "File is present"
  else
    echo "File is NOT present"
  fi
EHD
  echo -e "

  Con esto, ya puedes hacer todo lo que quieres con las condiciones.
  Nota que el \"commando\" puede ser tambien una funcion.
  Pero puede ser lento crear un commando o llamar una funcion para solo probar:
  - si un archivo exists
  - si dos string son eguales
  - si un numero es inferior a otro

  Por eso, vamos a recurir a protocolos internos de bash, que, como siempre, llamamos \"interpolaciones\".
"
abat << 'EHD'
  # Interpolacion de test con opciones heridas de la historia
  # -- -f = si el archivo existe
  if [[ -f present.txt ]]; then echo "File is present"; fi
  # -- ! = invierte la condicion
  if [[ ! -f not_present.txt ]]; then echo "File is not present"; fi

  # Interpolacion de test para igualda
  var="value"
  if [[ "$var" == "value" ]]; then echo YES; else echo NO; fi
  if [[ "$var" == "not_value" ]]; then echo YES; else echo NO; fi

  # Interpolacion arithmetica => tambien tiene un valor de retorno
  for i in {1..10}; do
    if ((i<=10/2)); then
      echo "$i is small"
    else
      echo "$i is big"
    fi
  done
EHD
  echo -e "

  Un error frecuente es un cerrar el blocke: con done, fi o } para respectivamente los cyclos, condiciones y funciones.
  Que pasa si no lo pones?

  Una otra palabra clase de condicion es \"elif\"
"
abat << 'EHD'
  var=4
  if ((var==2)); then
    echo two
  elif ((var==3)); then
    echo three
  elif ((var==4)); then
    echo four
  else
    echo other
  fi
EHD
  echo -e "

  Pero a veces puede ser feo de leer porque al final eso es un interuptor con distintos casos. Por lo tanto, lo que sigue, en C, se llama un \"switch\" o interuptor
"
abat << 'EHD'
  var=4
  case var in
    2)
      echo two
      ;;

    3)
      echo three
      ;;

    4)
      echo four
      ;;

    *)
      echo other;
      ;;
  esac
EHD
  echo -e "


${cblue}P04: Funciones$cend
  Antes de 1945 todo lo que precede se hacia con saltos condicionales e incondicionales.
  El codigo era naturalamente spaghetti.
  La invetion de las subroutinas (hoy dia llamada funciones) era simple, crear bloques de codigo llamados, asi el llamador llama el codigo por su nombre y sabe que el codigo var a volver con una repuesta.
  Nota: Antes no se sabia si un salto a volver => ver en C \"longjmp\" que todavia se usa en la terminal al hacer un commando porque a veces no vuelve, por ejemplo \"exec\").

  Asi que los \"CALL\" remplazaron unos \"JUMP\".
  En BaSh:
"
abat << 'EHD'
  # Declarar funciones
  hablar(){
    echo "esta funcion se llama hablar"
  }
  decir(){ echo "Esta funcion dice $1"; }
  blabla(){ echo "Este bla bal $@"; }

  # Llamar las funciones
  hablar "Este ni escuha sus argumentos"
  decir "Hola Jaime" "No escuacha al segundo"
  balbla "Este" "se va a comer" todo los argumentos
EHD
  echo -e "

  Nota que \$1 se refiere al primer argumento, \$2 al segundo, etc hasta el \$9. \$@ es una tabla con todo los argumentos.



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
