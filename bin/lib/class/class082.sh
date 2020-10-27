#!/usr/bin/env bash
# -- Tarea: Language, flujo de control y Regex
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  echo -e "$cblue
+=========================+
| Flujo de control: Tarea |
+=========================+$cend


${cblue}P01: Ir a (goto)$cend
  Es el mas antiguo de los controladores de flujo. Herede del salto (JUMP) en Assembly.
  Se llama \"goto\" va directamente a la linea que sigue la etiqueta \"label\") dado como argumento.
  Perl y C lo soportan.
  Copia eso en goto.pl:
  -->"
abat perl << 'EHD'
#!/usr/bin/env perl

use v5.25;

my $var=1;

START:
  say "start";
  goto LABEL2 if ($var == 2);
  goto LABEL1;

LABEL1:
  say "Label1";
  $var = 2 and goto START if ($var == 1);
  goto EXIT;

LABEL2:
  say "Label2";
  $var = 3;
  goto START;

EXIT:
  say "Exit";
  exit 0;
EHD
  echo -e "
  <--

  Ejecútalo:
  ${cyellow}> perl goto.pl$cend

  Intenta seguir lo que esta pasando. Hay muchos saltos. Es complicado seguirlos.
  Por eso el único goto que es legítimamente aceptado en la comunidad es el
  \"goto EXIT\" que permite liberar los recursos antes de salir en un mismo lugar,
  antes de la salida de una función.

  Mira, por ejemplo, del núcleo Linux, este driver (de pantalla): https://github.com/torvalds/linux/blob/3650b228f83adda7e5ee532e2b90429c03f7b9ec/drivers/hid/hid-picolcd_fb.c#L568-L578
  El enlace te muestra los labels, los goto están justo arriba. Estos multiples labels de salida estan aqui para que sea mas rápido. Por eso elije el núcleo. En un caso mas general, habrá un solo label EXIT y cada liberación va a verificar si el recurso merece realmente estar liberado


${cblue}P02: Ciclo$cend
  Lo ciclos son interesante para hacer múltiples veces la misma tarea.
  Aquí un ciclo que muestra los factores de todo los enteros de 1 a 100.
  ${cyellow}> for i in {1..100}; do factor $i; done$cend

  Haga un ciclo que crea los directorios dirXX donde XX es un numero de 1 a 99

  Siguiente ejercicio:
  -->"
abat << 'EHD'
  # Aquí como se hace un ciclo sobre cada elemento de una table (\"array\")
  array=(first second Third fourth)
  for i in "${array[@]}"; do
    echo $i;
  done

  # Aqui como se capitaliza la primera letra de una variable
  foo=bar
  ${foo^}
  # OUTPUTS: Bar
EHD
  echo -e "
  <--

  Haga un ciclo que pone capitaliza la primera letra de cada elemento de la cuadra de entrada y escribe el resultado en StdOut.


${cblue}P03: Condición$cend
  Las condiciones son útiles para efectuar una tarea solo en ciertos casos.
  Típicamente, si es posible o útil hacerla.

${cblue}P04: Función$cend


$cblue
+==============+
| Regex: Tarea |
+==============+$cend

Aconsejo buscar la linea de comando por si mismo antes de leer las repuesta
Para ver las repuesta corre:
${cyellow}> jim class082 p11$cend  # por ejemplo para la repuesta a la p11

${cblue}P11: Regex: Fin de palabra$cend
  Busca todos los patrones que constan de dos caracteres que terminan en \"y\" en /etc/passwd

${cblue}P12: Regex: Alternación$cend
  Muestra todas las líneas en /etc/passwd que contienen \"root\", \"bin\" o \"sync\"
  Mira bien que use la palabra o => alternación => |

${cblue}P13: Regex: Agrupación$cend
  Cuál es el resultado del siguiente comando: grep -P 'no(b|n)' /etc/passwd?
  Cuál es el efecto de usar paréntesis en esta expresión regular?
  Que pasa si las sacamos?

${cblue}P14: Regex: En tubo$cend
  Busque en las primeras 6 líneas de /etc/passwd líneas que contengan un carácter numérico
  Ayuda: las paginas manual de: perlreref, head, o sed (head es mas facil)

${cblue}P15: Regex: Cuantificador exacto$cend
  Ejecute el siguiente comando: grep -E '[0-9]{3}' /etc/passwd, cuál es su resultado

${cblue}P16: Regex: Pero el ojo humano primero$cend
  Ahora usaremos el comando wc para mostrar estadísticas sobre el resultado del comando \"${cyellow}ls -l$cend\".
  Muestra el número de directorios contenidos en /etc

${cblue}P17: Regex$cend
  Muestra el número de archivos normales contenidos en /etc

${cblue}P18: Regex$cend
  Muestra el número de archivos que tienen más de un enlace (el segundo numero tiene que ser superior a 1).
  Esta es dificil, puedes ver directo la repuesta ;-)


${cblue}P20: Regex$cend
  Ahora en adelante, las preguntas son mucho mas rápidas:
  Solo escribe la expresión regular que permitiría agarrar tal linea en el commando:
  ${cyellow}> grep -P 'Aqui_esta_la_exprecion'$cend

${cblue}P21: Regex$cend tiene una 'q'
${cblue}P22: Regex$cend comienza con una 'q'
${cblue}P23: Regex$cend tiene 'th'
${cblue}P24: Regex$cend tiene una 'q' o una 'Q'
${cblue}P25: Regex$cend tiene un '*' en él
${cblue}P26: Regex$cend comienza con una 'q' o una 'Q'
${cblue}P27: Regex$cend tiene 'a' y también 'e'
${cblue}P28: Regex$cend tiene una 'a' y en algún lugar después una 'e'
${cblue}P29: Regex$cend no tiene una 'a' ! Esa no la hemos visto, mira la repuesta.
${cblue}P30: Regex$cend no tiene una 'a' ni una 'e'
${cblue}P31: Regex$cend tiene una 'a' pero no una 'e'
${cblue}P32: Regex$cend tiene al menos 2 vocales consecutivas (a, e, i, o, u) como la \"io\" de la palabra \"rocio\"
${cblue}P33: Regex$cend tiene al menos 3 vocales
${cblue}P34: Regex$cend tiene al menos 6 caracteres
${cblue}P35: Regex$cend tiene exactamente 6 caracteres
${cblue}P36: Regex$cend 'Bar' o 'Baz'


${cblue}End:$cend
  Acabaste, felicitación, ya eres padawan en Regex.
  Créeme que son muy muy útiles.
  Desafortunadamente no puedo mostrarte todo los campos en que son usadas.

  Lo interesante es que son usadas el la misma interpretación de todo los lenguajes informáticos.
  Así que tienes todas la llaves para hacer tu propio idioma!

  Nos vemos para los servicios.
"

if [[ "$1" == "long" ]]; then
  echo -e "$cblue
+==================+
| Regex: Repuestas |
+==================+$cend
"
  for i in {11..18} {21..36}; do
    echo -ne "${cblue}R$i: $cend"
    "p$i"
  done
fi
}

p11(){ echo -e "${cyellow}grep -P '.y\\b' /etc/passwd$cend"; }

p12(){ echo -e "${cyellow}grep -P 'root|bin|sync' /etc/passwd$cend
o
${cyellow}grep 'root\|bin\|sync' /etc/passwd$cend
Nota que es mas fácil (menos escapes con -P para PCRE)";
}

p13(){ echo -e "Busca las cadenas de caracteres (\"string\") \"nob\" o \"non\".
El efecto de la paréntesis es la agrupar lo que esta adentro como si fuera un átomo.
Si las sacamos, la expresión regular busca \"nob\" o \"n\";"
}

p14(){ echo -e "${cyellow}head -n 5 /etc/passwd | grep \\d$cend
${cyellow}sed '6 q' /etc/passwd | grep '\\d'$cend
El comando con sed, hace un 'quit' después de imprimir la linea 6. Sed recibe un idioma, asi que es un poco mas versátil y difícil manejar que head que hace solo esta tarea."
}

p15(){ echo -e "Busca cadena de exactamente 3 cifras decimales"; }

p16(){ echo -e "Juega, lee la doc de ls o pregunta a un motor de búsqueda.
Fíjate que los directorios empiezan con un \"d\":
${cyellow}> ls -l /etc | grep -P '^d' | w$cend";
}

p17(){ echo -e "Lo mismo, no tiene que empezar con \"d\", ni \"l\" (para Link) sino \"-\" aparentemente cierto?
${cyellow}> ls -l /etc | grep -P '^-' | w$cend";
}

p18(){ echo -e "${cyellow}ls -l /etc | grep -P '^\\S+ +1 '$cend
  ^  = principio de linea
  \\S = ALgo que no sea un espacio (o tabulacion)
  +  = Ultimo atomo 1 o mas veces
  <space> = espacio literal
  +  = uno o mas veces
  1  = \"1\" literal";
}

p21(){ echo -e "${cyellow}q$cend  # literal"; }
p22(){ echo -e "${cyellow}^q$cend  # ^ para principio de linea"; }
p23(){ echo -e "${cyellow}th$cend  # literal"; }
p24(){ echo -e "${cyellow}q|Q$cend  # | para alternación"; }
p25(){ echo -e "${cyellow}\\*$cend   # Se debe escapar porque sino es el cuantificador de 0 a infinito osea cualquier numero de veces"; }
p26(){ echo -e "${cyellow}^(q|Q)$cend  # Hay que agrupar porque \"^q|Q\" coincide con lineas que comienzas con una q o tienen un Q (en cualquier lugar ya que la alternación tiene precedencia muy baja)"; }
p27(){ echo -e "${cyellow}a.*e|e>*a$cend  # A seguido poor e o e seguido por a. Deba haber otras formas"; }
p28(){ echo -e "${cyellow}a.*e$cend  # a, . = cualquier cosa, * = cualquier numero de veces, e"; }
p29(){ echo -e "${cyellow}^[^a]*\$$cend
^ = principio de linea
[^a]  = es una clase de carácter, y el \"^\", si esta al principio lo niega, entonces aquí es todo excepto un \"a\".
  Puedes ver mas sobre las clases de caracteres en internet, lo importante aquí es que es una alteración que permite \"coincidir con todo excepto\".
$ = fin de linea"; }
p30(){ echo -e "${cyellow}^[^ae]*\$$cend  # Principio de linea, ni a ni e cualquier numero de veces, fin de linea"; }
p31(){ echo -e "${cyellow}^[^e]*a[^e]*\$$cend  # Principio, non-e cualquier numero de caves, a, non-e cualquier veces, Fin"; }
p32(){ echo -e "${cyellow}[aeiou]{2}$cend  # a, e, i, o o y repetido exactamente 2 veces"; }
p33(){ echo -e "${cyellow}^(.*[aeiou]){3}$cend  # Principio de linea (no necesario pero mas rapido), lo que sea seguido por una vocal, y todo eso repetido 3 veces.
Debería empezar a entra un poco. La idea es que veas lo que se puede hacer."; }
p34(){ echo -e "${cyellow}^......$cend  # o \"${cyellow}^.{6}$cend\" que es lo mismo: cualquier caracter 6 veces."; }
p35(){ echo -e "${cyellow}^.{6}$$cend  # principio, cualquier carácter 6 veces, fin"; }
p36(){ echo -e "${cyellow}Ba(r\z)$cend  # Y se acabo, Bravo!"; }




get_fct_dic
call_fct_arg "$@"
