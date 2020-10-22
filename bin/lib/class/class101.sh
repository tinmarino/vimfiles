#!/usr/bin/env bash
# ${cblue}Syntax: Language$cend: Ecosystema: python, java, C, assembly
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+===========+
| Languages |
+===========+$cend

Los informaticos operacionales (mal llamados technicos o ingenieros) clasifican los idiomas en function del tipo de salida que se espera, una pagina web o unos bits para un micor controlador.
Es interesante para saber que idioma usar en que situacion. No se usa un idioma de tipo Assemblador como Shell (sino un interpretado), ni un interpretado para contrlar los reactores de una nave (o otro sistema tiempo real)

"
abat << 'EHD'
                         High Level
|-----------------+------------------------------+-------------------|
| Familly         | Description                  | Example           |
|-----------------+------------------------------+-------------------|
| Markup          | Format that describe data:   | Html, Pdf,        |
|                 | Text, Sound, Video, Web page | Xml, Json, LaTeX, |
|                 | or metaformat that describes | Css, Markdown,    |
|                 | it all (Html, Xml)           | Png, Mp3, Mp4     |
|-----------------+------------------------------+-------------------|
| Interpreted     | Sent to a program which      | BaSh, Python,     |
|                 | is executing it while        | Perl, JavaScript, |
|                 | reading                      | VimScript         |
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
                         Low Level
EHD
  echo -e "

Pero los investigadores en informatica prefieren referirse a su syntaxe y a sus paradigmos. 
Es interesante explicar eso a un alumno, pensar sobre eso para mejorar el codigo como interface humano maquina.
Ayuda en formular operaciones imbricandolas en palabras del idioma variables, funciones o objectos (que son ambos).
Muestra algo muy importante, es que lo que se entiende bien, se expresa bien, y se ejecuta bien. Asi que la elegancia y lisibilidad, la syntaxis cuenta.

* ${cred}Imperativos$cend
  * ${cred}Operativos$cend <= Lineares hasta un salto (Asm)
  * ${cred}Procedurales$cend <= con Call, es decir funciones, primera capade imbricacion
  * ${cred}Orientado Objecto$cend <= con Classes que son contenedores de variables y funciones. Aparecio naturalmente despues de tanto tiempo guardado las direciones de las funciones en variables
    -- Es recomandanto usar objectos cuando se puede ya que la herencia puede remplazar condiciones
* Declarativos
  * ${cred}Funcionales$cend <= El resultado es declarado como una serie de funciones aplicada. Basicamente no hay variables, el codigo de ejecuta de forma floja lo que permite optimizaciones durante la compilacion (Haskell).
    -- Es recommendado usar este paradigmo ya que los filtros y mappeos puedeen remplazar ciclos.
  * ${cred}Logicos$cend <= El humano declara la logicam la possibilidades y resticiones y el computador encuentra la solucion.
    -- Quizas ha sido de modo en los 1980, pero ya no lo es. Lo que es extremamente desafortuno porque el potencial es increible (Prolog, Gecode)
  * ${cred}Matematicos$cend <= El humano escribe una ecuacion, el computador la resolve de forma perfecta. (Mapple, Matematica)


Notas (importantes):
1. Cada paradigmo soporta un \"Nivel mas alto\" (Higher level programming) cuando el codigo genera codigo: operaciones crean operaciones, funciones que crean funciones, objectos que crean objectos, ecuaciones ....
2. Se puede hacer cualquier operacion con cualquier de estos languages mientras tenga la \"completitud de Turing\" lo que es el caso de todos los citados exepto los de Markups. Eso dicho, LaTeX que puse en markup es un Macro-Markup como lo puede ser Xml, y ambos son Turing complete (pero es muy hackeo)
3. Muchos idiomas soportan disintos paradimos. Se destacan Python y Java que los soportan todos!
4. Hoy dia es muy muy facil crear un idioma interpretado, se hace mucho para aplicaciones especifica, manejar un avion, controlar una cadena de producion. En ese caso se llama \"Language especifico a un dominio\" (Domain Specific Language: DSM). De alguna forma, \"Git\" es un DSM especifico al control de vercion.

Esta clase te va a hacer un tour de estos idiomas y las preguntas que te pueden salir relativa a tu cultura programatica.
Es mucho mas importante saber leer y depurar codigo que saber escribirlo.
Lo informaticos dicen: \"Un buen programador escribe buen codigo, un exelente programador reusa buen codigo\".



${cblue}End:$cend

  "

  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
