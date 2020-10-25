#!/usr/bin/env bash
# ${cblue}Sintaxis: Lenguaje$cend: Ecosistema: Niveles de idioma
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  echo -e "$cblue
+=======================+
| Languages: Categorias |
+=======================+$cend

${cblue}P01: Tipos de salida$cend

  Los informáticos operacionales (mal llamados técnicos o ingenieros) clasifican los idiomas en función del tipo de salida que se espera, una pagina web o unos bits para un micro controlador.
  Es interesante para saber que idioma usar en que situación. No se usa un idioma de tipo Asemblados como Shell (sino un interpretado), ni un interpretado para controlar los reactores de una nave (o otro sistema tiempo real)

"
abat << 'EHD'
                           High Level
  |-----------------+------------------------------+-------------------|
  | Familly         | Description                  | Example           |
  |-----------------+------------------------------+-------------------|
  | Domain Specific | Usually short, to manage a   | Git, SQL, Dot     |
  | Language        | tack specific to one domain  | Sed, Awk,         |
  |                 |                              | PCRE (=RegExp)    |
  |-----------------+------------------------------+-------------------|
  | Markup          | Format that describe data:   | Html, Pdf,        |
  |                 | Text, Sound, Video, Web page | Xml, Json, LaTeX, |
  |                 | or metaformat that describes | Css, Markdown,    |
  |                 | it all (Html, Xml)           | Png, Mp3, Mp4     |
  |-----------------+------------------------------+-------------------|
  | Interpreted     | Sent to a program which      | BaSh, Python,     |
  |                 | is executing it while        | Perl, JavaScript, |
  |                 | reading                      | Ruby, Php         |
  |-----------------+------------------------------+-------------------|
  | Pseudo-Compiled | A compiler transform it      | Java              |
  |                 | to pseudo code and a         | Web-Assembly      |
  |                 | virtual machine execurtes    |                   |
  |-----------------+------------------------------+-------------------|
  | Compiled        | Compiled to bytecode by      | C, C++, Rust,     |
  |                 | GNU Compiler Collection      | Fortran, Haskell, |
  |                 | or friends                   | (Cobol, Pascal)   |
  |-----------------+------------------------------+-------------------|
  | Assembly        | Mnemonics that map directly  | Asm, Masm, Nasm   |
  |                 | to machine code operation    |                   |
  |                 | Like Alias for bytecode      |                   |
  |                 | operation                    |                   |
  |-----------------+------------------------------+-------------------|
  | ByteCode        | Binary format (.exe or .so)  | Intel, ARM,       |
  |                 | That is sent to the CPU      | MIPS, RISC        |
  |                 | electromagnetically from     |                   |
  |                 | the RAM                      |                   |
  |-----------------+------------------------------+-------------------|
  | Hardware        | Create instructions to       | VDHL, Verilog     |
  | description     | generate hardware:           |                   |
  |                 | CPU, building                |                   |
  |-----------------+------------------------------+-------------------|
                           Low Level
EHD
  echo -e "

${cblue}P02: Tipos de sintaxis$cend
  Pero los investigadores en informática prefieren referirse a su sintaxis y a sus paradigmas.
  Es interesante explicar eso a un alumno, pensar sobre eso para mejorar el código como interfase humano maquina.
  Ayuda en formular operaciones imbricándolas en palabras del idioma variables, funciones o objectos (que son ambos).
  Muestra algo muy importante, es que lo que se entiende bien, se expresa bien, y se ejecuta bien. Así que la elegancia y legibilidad, la sintaxis cuenta.

  * ${cred}Imperativos$cend
    * ${cred}Operativos$cend <= Lineares hasta un salto (Asm)
    * ${cred}Procesal$cend <= con Call, es decir funciones, primera capa de imbricación
    * ${cred}Orientado Objecto$cend <= con Clases que son contenedores de variables y funciones. Apareció naturalmente después de tanto tiempo guardado las direcciones de las funciones en variables
      -- Es recomendando usar objectos cuando se puede ya que la herencia puede remplazar condiciones
  * Declarativos
    * ${cred}Funcionales$cend <= El resultado es declarado como una serie de funciones aplicada. Básicamente no hay variables, el código de ejecuta de forma floja lo que permite optimizaciones durante la compilación (Haskell).
      -- Es recomendado usar este paradigma ya que los filtros y cartografías pueden remplazar ciclos.
    * ${cred}Lógicos$cend <= El humano declara la lógica, las posibilidades y restricciones y el computador encuentra la solución.
      -- Quizás ha sido de modo en los 1980, pero ya no lo es. Lo que es extremamente desafortunado porque el potencial es increíble (Prolog, Gecode)
    * ${cred}Matemáticos$cend <= El humano escribe una ecuación, el computador la resuelve de forma perfecta. (Mapple, Matematica)


  Notas (importantes):
  1. Cada paradigma soporta un \"Nivel mas alto\" (Higher level programming) cuando el código genera código: operaciones crean operaciones, funciones que crean funciones, objectos que crean objectos, ecuaciones ....
  2. Se puede hacer cualquier operación con cualquier de estos lenguajes mientras tenga la \"completitud de Turing\" lo que es el caso de todos los citados excepto los de Markups. Eso dicho, LaTeX que puse en markup es un Macro-Markup como lo puede ser Xml => LaTex, Css son Turing complete (pero es muy hackeo)
  3. Muchos idiomas soportan distintos paradigmas. Se destacan Python y Java que los soportan todos!
  4. Hoy día es muy muy fácil crear un idioma interpretado, se hace mucho para aplicaciones especifica, manejar un avión, controlar una cadena de producción. En ese caso se llama \"Lenguaje especifico a un dominio\" (Domain Specific Language: DSM).

Esta clase te va a hacer un tour de estos idiomas y las preguntas que te pueden salir relativa a tu cultura programática.
Es mucho mas importante saber leer y depurar código que saber escribirlo.
Lo informáticos dicen: \"Un buen programador escribe buen código, un excelente programador reusa buen código\".


${cblue}P03: Lista de idiomas$cend
  Wikipedia: Puedes ver la lista de los lenguajes de programación:
  https://en.wikipedia.org/wiki/List_of_programming_languages

  Stackoverflow: Es el foro donde se responden preguntas relacionadas a la programación. Hace una encuesta anual (muy interesante):
  https://insights.stackoverflow.com/survey/2020#technology-programming-scripting-and-markup-languages

  StackEchange: Y puedes descargar los datos crudos que quieres (en SQL) ahí:
  https://data.stackexchange.com/stackoverflow/query/new

  Github: Es un sitio bastante usado para la fuente abierta.
  Ya que tiene una API, se puede buscar los lenguajes los mas usados.
  El resultado que sigue es coherente con StackOverflow:
  https://github.com/oprogramador/github-languages

  RosetaCode: tiene retazos (\"snippets\") en todo los idiomas
  Ayuda a la traducción como la piedra de Roseta.
  De ahí saque la mayoría del código que sigue
  http://www.rosettacode.org

$cblue
+=====================+
| Lenguajes: Ejemplos |
+=====================+$cend

${cblue}P21: Lenguajes específicos a un dominio (Dot)$cend
  Vamos a ver un idioma de descripción de gráfico: Dot de Graphviz.
  ${cyellow}> sudo apt install graphviz$cend
  Copia lo ue sigue en ex.dot
"
abat dot << 'EHD'
digraph D {

  A [shape=diamond]
  B [shape=box]
  C [shape=circle]

  A -> B [style=dashed, color=grey]
  A -> C [color="black:invis:black"]
  A -> D [penwidth=5, arrowhead=none]

}
EHD
  echo -e "

  Compila y abre la salid
"
abat << 'EHD'
  dot -Tpng ex.dot -o ex.png
  xdg-open ex.png
EHD
  echo -e "


${cblue}P22: Lenguaje de markup (Markdown)$cend
  Markdown tiene la ventaja que se escribe casi como se vee:
  ${cyellow}> sudo apt install pandoc$cend
  Copia lo que sigue en ex.md

  -->"
abat markdown<< 'EHD'
# This __bold__ in title

And _italic_ in paragraph
1. A
2. Small
3. List [Link to cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

And a table:

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.

<p style="color:red">Soporta HTML tag incluido</p>
<p style="color:blue">Lo que es necesario para los colores por ejemplo</p>
EHD
  echo -e "
  <--

  Compilalo y observa el resultado
"
abat << 'EHD'
  pandoc ex.md -o ex.html && xdg-open ex.html
EHD
  echo -e "


${cblue}P23: Lenguaje interpretado (Javascript)$cend
  Javascript es el idioma que corre el el navegador cuando Html y Css no es bastante interactivo.
  Es el lenguaje el mas popular del planeta
  Puedes ver un ejemplo ahí: https://js1k.com/2017-magic/demo/2679
  Abre firefox, aprieta F12, pega lo que sigue en el prompt abajo:

  -->"
abat javascript << 'EHD'
// Crea una variable
let d = new Date();

// Cambia el contenido de la pagina
document.body.innerHTML = "<h1>Today's date is " + d + "</h1>"

// Cambia el estylo
document.body.style.backgroundColor = "lightblue";

// Crea nodos = tag dynamicamente
let p = document.createElement("P");
let t = document.createTextNode("Paragraph text.");
p.appendChild(t);
document.body.appendChild(p);
EHD
  echo -e "
  <--

  Nota que cuando JavaScirpt encuentra errores, sigue la ejecución igual.
  Es un idioma interpretado con una especificación perfectamente descrita para que se ejecute igual en distintos navegadores, para que Internet funciones
  Es un poco lento, por eso nació en WebAssembly


${cblue}P24: Lenguaje Pseudo Compilado (Java)$cend
  Java es el ejemplo natural de esta categoría.
  ${cyellow}> sudo apt install default-jre$cend
  Copia en Ex.java

  -->"
abat java << 'EHD'
public class Ex {
    public static void main(String[] args) {
        for (int i = 1; i <= 12; i++)
            System.out.print("\t" + i);

        System.out.println();
        for (int i = 0; i < 100; i++)
            System.out.print("-");
        System.out.println();
        for (int i = 1; i <= 12; i++) {
            System.out.print(i + "|");
            for(int j = 1; j <= 12; j++) {
                if (j >= i)
                    System.out.print("\t" + i * j);
            }
            System.out.println();
        }
    }
}
EHD
  echo -e "
  <--
"
abat << 'EHD'
  # Pseudo-compilalo (Java Compiler)
  javac Ex.java

  # Ejecutalo (el la Java Virutal Machine)
  java Ex

  # Intenta leer el archivo Ex
  cat Ex  # Oups no existe ...

  # ... Porque es Ex.class
  cat Ex.class  # Asi se ve un codigo pseudo compilado
EHD
  echo -e "


${cblue}P25: Lenguaje Compilado (C)$cend
  C es el idioma compilado mas usado. Es un idioma sistema, permita comunicar con el núcleo o adentro del núcleo con los dispositivos.
  Se puede compilar para muchas arquitecturas distintas.
  Los núcleos de Linux y Windows están escrito en C, hoy (2020) se debe escribir en C un piloto Linux. Windows permite C++
  Su único rival es Rust (todavía guaguita)

  -->"
abat c << 'EHD'
#include <stdio.h>

void pascaltriangle(unsigned int n)
{
  unsigned int c, i, j, k;

  for(i=0; i < n; i++) {
    c = 1;
    for(j=1; j <= 2*(n-1-i); j++) printf(" ");
    for(k=0; k <= i; k++) {
      printf("%3d ", c);
      c = c * (i-k)/(k+1);
    }
    printf("\n");
  }
}

int main()
{
  pascaltriangle(8);
  return 0;
}
EHD
  echo -e "
  <--
"
abat << 'EHD'
  # Compila (Gnu Compiler Collection)
  gcc ex.c -o ex

  # Correlo (Como cualquier ejecutable
  ./ex
EHD
  echo -e "


${cblue}P26: Lenguaje Asemblado (Nasm)$cend
  Nasm es un lenguaje asemblado abierto.
  ${cyellow}> sudo apt install nasm$cend
  También cada fabricante de procesador tiene su propio idioma.
  Gcc los conoce todos.
  Escribe e un archivo hello.asm:

  -->"
abat asm << 'EHD'
; Define variables in the data section
SECTION .DATA
	hello:     db 'Hello world!',10
	helloLen:  equ $-hello

; Code goes in the text section
SECTION .TEXT
	GLOBAL _start

_start:
	mov eax,4            ; 'write' system call = 4
	mov ebx,1            ; file descriptor 1 = STDOUT
	mov ecx,hello        ; string to write
	mov edx,helloLen     ; length of string to write
	int 80h              ; call the kernel

	; Terminate program
	mov eax,1            ; 'exit' system call
	mov ebx,0            ; exit with error code 0
	int 80h              ; call the kernel
EHD
  echo -e "
  <--
"
abat << 'EHD'
  # Assembla lo
  nasm -f elf64 hello.asm -o hello.o

  # Linkealo
  ld hello.o -o hello

  # Executalo
  ./hello
EHD
  echo -e "

  También puedes generar código asemblado desde codigo c.
  Escribe hi.c;

  -->"
abat << 'EHD'
#include <stdio.h>

int main(int argc, char** argv){
  printf("Hi Jim\n");
  return 0;
}
EHD
  echo -e "
  <--
"
abat << 'EHD'
  # Assemblealo (en Gas para Gnu ASsembly)
  gcc hi.c -S -o hi.S

  # Mira el codigo assembly (:q! para salir)
  vi hi.S

  # Compilalo
  gcc -c hi.S -o hi.o

  # Linkealo
  gcc hi.o -o hi

  # Executalo
  ./hi
EHD
  echo -e "


${cblue}P27: Lenguaje binario (Bin)$cend
  El código binario esta escrito en 0 y 1 como 0000101101110001.
  Pero es mas eficiente verlo en hexadecimal donde
  00 -> 00000000
  FF -> 11111111

  No vamos a escribir código binario pero lo vamos a leer (en hexadecimal)
"
abat << 'EHD'
  # Desassemblealo:
  # -- En segmento .DATA como string <= s
  # -- El segmento .TEXT como codigo desassembleado <= d
  objdump -sj .DATA hello && objdump -dj .TEXT hello

  # Mira su contenido crudo
  cat hello | xxd

  # Lo quieres ver con 1 y 0?
  cat hello | xxd -b
EHD
  echo -e "


${cblue}P28: Lenguaje descriptivo de hardware (VHDL)$cend
  Para crear un CPU, ya no se dibuja cada circuito.
  Se escribe las especificaciones (lo que uno quiere en entrada y en salida) que, pasando por un generador, crean un archivo que describe la arquitectura, posición de los circuitos.
  El primer CPU (Controlador) que se crear vale 1 millón de dolares porque hay que configurar las maquinas para eso. Los siguientes valen menos de 1 dolar cada uno. Por lo tanto se crean millones de una, hay que estar seguro antes de mandar el plan a Vietnam o China.
  Por eso existen field-programmable gate array (FPGA) que son procesadores que se pueden configurar. Pueden servir para hacer los prueba del código VDHL o para tener un CPU con operaciones especificas.

  ${cyellow}sudo apt install ghdl$cend

  Escribe en counter.vhdl:

  -->"
abat vhdl << 'EHD'
-- Importa las bibliotecas, necesario para los IO (aqui solo reset para acabar)
library ieee ;
use ieee.std_logic_1164.all;

-- Declara las entradas y salidas de esta entidad
entity counter is
  port(
    reset:  in  std_logic
  );
end;

-- Implementa el trabajo de la entidad
architecture behav of counter is
begin
  -- Declare un proceso con nombre, que solo se lanza al reset
  count_to_10: process(reset)
  begin
    -- Da 10 vuelvas
    for I in 1 to 10 loop
       -- Imprime la concatenacion "&" de un literal y del valor de la variale I (entera)
       report "I = " & integer'image(I);
    end loop;
  end process;
end behav;
EHD
  echo -e "
  <--
"
abat << 'EHD'
  # Analysa (es como compilar)
  ghdl -a --ieee=synopsys counter.vhdl

  # Genera el Ejecutable
  ghdl -e --ieee=synopsys counter

  # Corre (Run) en un component FPGA virtual
  ghdl -r --ieee=synopsys counter
EHD
  echo -e "



${cblue}End:$cend
  Hemos visto un zoológicos de idioma del código a la ejecución.

  Acuérdate que hay distintas forma de catalogar un lenguaje (nivel de ejecución, sintaxis) pero no hay idiomas \"malos\", \"complicados\" o \"débiles\".
  El \"débil\" es el humano que pronuncia esta palabras porque es \"complicado\" trabajar con este weon \"malo\".
  Por lo tanto, no temes ni el nivel de ejecución, ni el tipo de sintaxis y entraras en la familia de los informáticos agnósticos del idioma (\"lenguaje agnóstico software enginneers\"). Lo mejor de esta familia, es que el boleto de entrada es gratis. Bienvenido!

  Tag: > dot > pandoc > xdg-open > gcc > java > javac > ld > nasm > hexdump > xxd > ghdl
  "
}

get_fct_dic
call_fct_arg "$@"
