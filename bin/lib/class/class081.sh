#!/usr/bin/env bash
# ${cblue}Syntax: Language$cend: Funcion, Rama, Ciclo y Regex
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  echo -e "$cblue
+==========+
| Lenguaje |
+==========+$cend

Escribir lenguajes informáticos es el trabajo de los desarrolladores.
No es (para nada) la parte mas difícil de la informática. Al contrario.
Es el principio. Empezaste tu estudios con eso y yo también.
Tal como un niño empieza su vida intelectual aprendiendo a hablar pero al crecer, puede estudiar literatura hasta los 80 años (y mas).
En todo caso, si no sabe hablar, esta cagado!

Un idioma informático es muy básico. Tiene 50 palabras en 5..10 grupos lexicales (nombre, verbo, adjetivo) distintos. Aquí son: comando, argumento, variable, controlador, comentario, operador.


${cblue}P01: Un ejemplo gramatical$cend
  > if [[ 1 == 1 ]]; then let a=42; else let a=31; fi; echo $a  # Que pasa
    ^- controlador         ^- comando         ^- variable       ^- comentario
            ^- operador                           argumento -^


${cblue}P02: Ciclo$cend
  Hay distintas formas de hacer un ciclo, iterar sobre una lista o repetir una tarea cambiando un contador hasta que una cierta condición ya no sea valida.
  Empezamos con la lista. La generamos con interpolación de rango \"{1..10}\"
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

  Bastante fácil no?
  El mismo ciclo con sintaxis tipo C
  Observa las dobles paréntesis que hacen pensar en una interpolación aritmética
"
abat << 'EHD'
  for ((i=1; i<=10; i=i+1)); do
    echo "i = $i";
  done
EHD
  echo -e "

  El mismo ciclo con el ciclo \"Mientras\"
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
  Nota que \$? es una variable que tiene el valor de retorno del comando anterior
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


${cblue}P03: Condición$cend
  Cuando un quiere ejecutar código solo en ciertos casos.
  La forma canónica es ejecutar un bloque si un comando tiene éxito

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
  Nota que el \"comando\" puede ser también una función.
  Pero puede ser lento crear un comando o llamar una función para solo probar:
  - si un archivo existe
  - si dos string son iguales
  - si un numero es inferior a otro

  Por eso, vamos a recurrir a protocolos internos de bash, que, como siempre, llamamos \"interpolaciones\".
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

  Un error frecuente es un cerrar el bloque: con \"done\", \"fi\" o \"}\" para respectivamente los ciclos, condiciones y funciones.
  Que pasa si no lo pones?

  Una otra palabra clase de condición es \"elif\"
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

  Pero a veces puede ser feo de leer porque al final eso es un interruptor con distintos casos. Por lo tanto, lo que sigue, en C, se llama un \"switch\" o interruptor
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
  El código era naturalmente espagueti.
  La invención de las subrutinas (hoy día llamada funciones) era simple, crear bloques de código llamados, así el llamador llama el código por su nombre y sabe que el código va a volver con una repuesta.
  Nota: Antes no se sabia si un salto a volver => ver en C \"longjmp\" que todavía se usa en la terminal al hacer un comando porque a veces no vuelve, por ejemplo \"exec\").

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

  Nota 1:
  - La variable \$1 se refiere al primer argumento, \$2 al segundo, etc hasta el \$9.
  - La variable \$@ es una tabla con todo los argumentos.

  Nota 2:
  Edsger Dijkstra (1930 - 2002) formulo el patrón de la entrada única y salida única de una función.
  Eso es lo que llevo a definir las funciones como las conocemos hoy día: la llamas a su entrada y el flujo de control vuelve a ti, una vez la función ejecutada.
  Este patrón ahora es muy mal interpretado. Por ejemplo la gente viene a pensar que una función puede tener solo una palabra clave \"return\", cuando, al contrario, salida temprana es recomendada en caso de error o de no necesidad de trabajo por ejemplo.
  Acuérdate que el patrón \"Single Entry, Single Exit\" es lo que define una función y lo usan todo los idiomas modernos (después de Fortran 1966) y en ningún caso un restricción de salir al toque.


${cblue}P05: Alan Turing (1912 - 1954)$cend
  Es el padre de los informáticos transformo las matemáticas de la computación en la informática que, como sabes, hoy día es un ciencia aparte,
  La informática es mas cerca de la matemáticas que cualquier otra ciencia por la única razón que es la ultima que se separo (digamos en 1955).
  Por la misma razón Galileo Galilei (1564 - 1642) es el padre de los físicos.

  Quisiera comentar 2 cosas (de sus trabajos): el problema de la parada y la maquina de Turing

  ${cblue}5.1 Problema de la parada (1936)$cend
  \"En el caso general, es imposible saber si un programar va a llegar a su salida o no\" y un corolario inmediato, no se puede saber si va a ejecutar una cierta rama, y el segundo corolario, es imposible estar seguro de lo que va a hacer. Entiende bien que hablamos de un caso general y no de programas particulares, que a 99% se puede leer y predecir.
  Este theorema de la parada de Truing (1936) es un correlario de los teoremas de incompletitud de Gödel (1931) que stipula que \"Cualquier teoría aritmética recursiva que sía consistente ye incompleta\".
  Ambas pruebas recursivamente absurdas, Turing copio Godel hasta en la prueba. Aqui esta la de Turing en Python:
"
abat << 'EHD'
  # Prueba del theorema de la parada (fuente Wikipedia)
  def termina(p):
      # Supongamos que aquí se encuentra un código maravilloso que soluciona el problema de la parada
      # Esta función regresa True si el programa p termina o False en otro caso

  # Funcion principal recursivamente absurda
  def main():
      if termina(main):
          ciclo_eterno()  # while True: pass  # en Python

  # LLama la funcion principal
  main
EHD
  echo -e "

  En castellano, si podemos saber que un programa termina o no, se puede construir un programa que si termina, no termina y si no termina, termina.
  Lo que es absurdo => no se puede saber de forma genérica si un programa termina, osea la función \"termina\" nunca se podrá escribir.

  Nota que esta absurdidad venida de Gödel revoluciono las matemáticas también.
  Conclusión 2: Lo que se puede entender y formular bien gana sobre lo incomprehensible


  ${cblue}5.2 Maquina de Turing (1936)$cend
  Una maquina de Turing tiene 2 operaciones llamada transiciones:
  1. Mover a la derecha
  2. Mover a la izquierda

  Tiene un estado interno (variables), un alfabeto (sintaxis) y un código de entrada
  Así se representa:

"
abat << 'EHD'
Input:
01
┌─────────────┬─────────┬──────────┬─────────────┬─────────────┐
│ STATE: q0   │ READ: 0 │ WRITE: o │ GO TO: qo1  │ MOVE: RIGHT │
└─────────────┴─────────┴──────────┴─────────────┴─────────────┘
╔═▼═╗───┬───┬────
║ 0 ║ 1 │ B │ ···
╚═▲═╝───┴───┴────

┌─────────────┬─────────┬──────────┬─────────────┬─────────────┐
│ STATE: qo1  │ READ: 1 │ WRITE: i │ GO TO: qrb  │ MOVE: RIGHT │
└─────────────┴─────────┴──────────┴─────────────┴─────────────┘
┌───╔═▼═╗───┬────
│ o ║ 1 ║ B │ ···
└───╚═▲═╝───┴────

┌─────────────┬─────────┬──────────┬─────────────┬─────────────┐
│ STATE: qrb  │ READ: B │ WRITE:   │ GO TO: qa   │ MOVE:       │
└─────────────┴─────────┴──────────┴─────────────┴─────────────┘
┌───┬───╔═▼═╗────
│ o │ i ║ B ║ ···
└───┴───╚═▲═╝────
EHD
  echo -e "

  Se puede demostrar que es posible construir una máquina especial de este tipo que pueda realizar el trabajo de todas las demás. Esta máquina especial puede ser denominada máquina universal.
  Unos 15 años después nace la informática (1950), el transistor también ayudo <= física cuántica de ... también 1936! Y 20 anos después (1969), el humano pisa la luna.
  Tienes que entender que la machina de Turing no es una vieja maquina pasada, es un modelo matemático que representa cualquier computador y que permita a cualquier computador simular cualquier otro.


$cblue
+===================+
| Expresión regular |
+===================+$cend

Una expresión regular es una secuencia de caracteres que conforma un patrón de búsqueda.
Es como un sub-idioma.

El idioma consiste en átomos, multiplicadores y alteraciones.
Una buena referencia es:

${cyellow}> man perlreref$cend

No olvides que Perl significa: \"Pattern Extraction and Report Language\".
Y extracción de patrones se hace mediante expresiones regulares.

Muy fácil:
  AlfaNum: Los caracteres alfa numéricos como 1, 3, s, b significan estos caracteres literales, excepto si están escapados como, \\1, \\3, \\s, \\b en cual caso, toman un significado especial
  Puntuación: La puntuación como: ., ?, (, [, * tiene un significado especial excepto si están escapado como: \\, \\? ,\\(, \\[ en cual caso, tienen un significado literal


${cblue}P01: Un ejemplo gramatical$cend
  ${cyellow}> grep -P '^(cat|echo) .*\|.*$' abs.txt$cend

  ^  ---------  principio de linea (átomo)
  (  ---------  empezar grupo (token)
    cat  -----  \"cat\" literal (serie de átomos)
    |  -------  o (alteración)
    echo  ----  \"echo\' literal
  )  ---------  cierra grupo
  <espacio>  -  espacio literal
  .  ---------  cualquier carácter (átomo)
  *  ---------  cualquier numero de veces (cuantificador)
  \| ---------   \"|\" literal
  .* ---------  cualquier carácter, cualquier numero de veces
  $  ---------  fin de linea (átomo)

  Lo que coincide (match) con:
  -- cat o echo al principio de la linea seguido por
  -- un espacio y cualquier numero de cualquier caracteres (\".*\") seguidos por
  -- un tubo \"|\" seguido por cualquier numero de cualquier caracteres (\".*\") seguido por
  -- el fin de la linea

  Puedes ya adivinar que \".*\" se usa mucho en RegEx


${cblue}P22: Descarga el libro Advanced Bash Scripting$cend
  Ya deberías tenerlo del la clase 6:
  "
  abat <<< '  wget -qO- https://tldp.org/LDP/abs/abs-guide.txt.gz | gunzip - > abs.txt'
  echo -e "


${cblue}P23: Corta el contenido del libro, principio de linea (^)$cend
  Aquí vemos nuestra primera expresión regular en sed:
  ^Chapter => Match principio de linea (\"^\") seguido por literalmente \"Chapter 2\"
  "
  abat <<< "  cat abs.txt | sed '/^Chapter 3/ q' > ab.txt"
  echo -e "

  Sed hace para cada linea el comando pasado en parámetro.
  Aquí el comando es: si la linea coincide con el patrón entre \"/\", quit (\"q\")


${cblue}P24: Estar o no estar: cuantificadores (?)$cend
  Hay distintos dialectos de expresiones regulares.
  Vamos usar las de Perl: PCRE para Perl Compatible Regular Expression
  Por lo tanto, agregaremos la opción \"-P\" a grep
  Ademas para evitar que el argumento se divide o expande o interpole, lo pondremos entre simples citas

  Queremos encontrar las palabras \"sh\" o \"bash\"
  "
  abat <<< "  grep -Pi 'b?a?sh'"
  echo -e "

  -P: Expresión regular en formato Perl
  -i: Ignore case = pude ser mayúscula o minúscula

  El patron es:
  b? = \"b\" o nada (\"?\")
  a? = \"a\" o nada (\"?\")
  sh = \"sh\"

  Mira la parte \"SYNTAX\" (opcionalmente \"QUANTIFERS\") del manual.
  Tienes que entender ?, * y +
  De hecho, vamos a buscar en el manual (o en Vim) con \"/\". En Nano aprieta f1 para obtener ayuda.


${cblue}P25: Regex a átomo: agrupar (())$cend
  El problema de la RegEx precedente es que puede coincidir con \"bsh\" o \"ash\".
  Mira que aparece \"f${cred}ash${cend}ion\" y \"Su${cred}bsh${cend}ells\"
  Por eso queremos \"ba\" o nada, es decir tratar \"ba\" como un átomo.
  Eso se llamar agrupar (gruping) y se hace mediante paréntesis, como en una ecuación matemática.
  "
  abat <<< "  grep -Pi '(ba)?sh'"
  echo -e "

  El patrón es:
  (ba)? = \"ba\" o nada
  sh = \"sh\"

  Así, si queremos coincidir con el SheBang #!/bin/bash
  "
  abat <<< "  abagrep -Pi '#!\/bin\/b?a?sh' ab.txt"
  echo -e "

  Nota solamente que tubo que escapar los \"/\" -> \"\\/\" que tienen un significado especial (Principio y fin de regex)


  ${cblue}P26: Alteraciones (|)$cend
  Con múltiples grep en un tubo, podemos filtrar exclusivamente, pero como hacemos si queremos filtrar dos patrones inclusivamente?
  Usamos la alteración, que es lo ultimo de la clase, acuérdate: Átomos, Cuantificadores y Alteraciones
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
  Un atomo interesante para lo que sigue es \"un dígito, es decir entre 0 y 9\".
  Se puede escribir, de la vieja forma como \"[0-9]\" que significa literalmente entre 0 y nueve.
  O con Perl \"\\d\" como Dígito, que es mas rápido de escribir
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


${cblue}End:$cend
  Felicitación: hemos visto:

  BaSh: Los ladrillos del control de flujo en programación:
  -- Función, Rama, Ciclo

  Expresiones Regulares: Un idioma especifico al buscar patrones:
  -- Alternación, Cuantificación, Agrupación

  La tarea te hara poner la manos arriba sobre el control de flujo y las expreciones regulares
  Mañana veremos los servicios y servidores.
  Nos vemos!
  "
}

get_fct_dic
call_fct_arg "$@"
