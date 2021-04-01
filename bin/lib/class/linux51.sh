#!/usr/bin/env bash
# ${cblue}Syntax: Monolinea$cend: Recreo
#
# shellcheck disable=SC2154  # cblue is referenced but not
# shellcheck disable=SC2016  # Expressions don't expand in single quotes

source "$(dirname "${BASH_SOURCE[0]}")/../../shellutil.sh"

__usage(){
  echo -e "$cblue
+===========+
| Monolinea |
+===========+$cend

Pare la primera clase de la segunda parte, vamos a jugar!
Un escript Monolinea (One Liner) es un programa que mide una linea.
Tiene ventaje en la portabilidad (facil copiar pegar, buscar en tu historial) y genericidad (no es muy personalisado).
Los commandos Linux responden a la filosofia: \"hacer una cosa y hacerla bien\".
Entonces, para las tareas del cotidiano, estas operaciones atomicas suelen combinarse en tubos, ejecuciones en serie o paralelo en lo que se llama monolineas.

Haga triple click para selectionar la linea

for i in {1..10}
do
    echo ${i}
done

for i in {1..10} ; do echo ${i} ; done

for i in {1..100} ; do touch File-\${i} ; done
ls File-* | wc -l


${cblue}P11: Descarga el libro Advanced Bash Scripting$cend"
  abat <<< 'wget -qO- https://tldp.org/LDP/abs/abs-guide.txt.gz | gunzip - > abs.txt'
  echo -e "
  wget: web get:
    -q = suprime la salida estándar (los mensaje)
    -O- es del alfabeto y no cero, escribe en la salida estándar lo que descargo
  gunzip: despaquetea
    - = entrada estandar
  ${cyellow}> cat abs.txt$cend  # Un archivo con texto humano (ingles)


${cblue}P12: Muestra los 10 archivos abiertos los mas largos$cend"
abat << 'EOH'
lsof / | awk '{ if($7 > 1048576) print $7/1048576 "MB" " " $9 " " $1 }' | sort -n -u | tail
EOH
  echo -e "


${cblue}P13: Tira un dado:$cend"
abat <<< 'echo Dado: $(shuf -i 1-6 -n 1)'
  echo -e "


${cblue}P14: Escanea todo los puertos abiertos de todas las interfaces accesibles$cend"
abat << 'EOH'
ifconfig -a | grep -Po '\b(?!255)(?:\d{1,3}\.){3}(?!255)\d{1,3}\b' | xargs nmap -A -p0-
EOH
  echo -e "


${cblue}P15: Busca las palabras mas utilizadas$cend"
abat << 'EOH'
tr -c a-zA-Z '\n' < abs.txt  | sed '/^.\{1,2\}$/d' | sort | uniq -i -c | sort -n
EOH
  echo -e "


${cblue}P16: Busca los procesos que usan mas RAM$cend"
abat << 'EOH'
ps aux | awk '{if ($5 != 0 ) print $2,$5,$6,$11}' | sort -k2n
EOH
  echo -e "


${cblue}P17: Busca los 10 comandos los mas usados$cend"
abat << 'EOH'
awk '{print $1}' ~/.bash_history | sort | uniq -c | sort -n
EOH
  echo -e "
  O"
abat << 'EOH'
history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n10
EOH
  echo -e "

$cblue
+--------------------+
| Efectos especiales |
+--------------------+$cend
Ctrl-l : cLear terminal (mas rápido que escribir \"> clear\")

${cblue}P20: 10 PRINT CHR\$(205.5+RND(1)); : GOTO 10$cend
  10 PRINT es un libreo de 300 paginas sobre esta linea de comando.
  Arriba en BASIC, abajo en BaSh, mas ahi: https://10print.org/
  Bienvenido en el mundo del \"hackeo\"
    <= palabra que se usa tambien para referirse al escribir programas muy pequeños y elegantes"
abat << 'EOH'
while :; do printf \\$(printf '%o' $[47+45*(RANDOM%2)]); done
EOH
  echo -e "


${cblue}Imprime la table de caracteres ascii$cend"
abat <<< 'for i in {32..255};do ((i%16==0))&&echo;printf "\\$(printf "%o" $i) ";done|iconv -f cp437 -t utf8'
  echo -e "
  O"
abat << 'EOH'
awk 'BEGIN {for (i = 32; i < 127; i++) printf "%3d 0x%02x %c\n", i, i, i}' | pr -t6 -w78
EOH
  echo -e "
  Pero ahi, mejor leer:
  ${cyellow}> man ascii$cend


${cblue}Extranas tu vieja TV$cend"
abat << 'EOH'
P=(' ' █ ░ ▒ ▓);while :;do printf "\e[$[RANDOM%LINES+1];$[RANDOM%COLUMNS+1]f${P[$RANDOM%5]}";done
EOH
  echo -e "


${cblue}El efecto del caballero$cend"
abat << 'EOH'
while :;do for i in {1..20} {19..2};do printf "\e[31;1m%${i}s \r" █;sleep 0.02;done;done
EOH
  echo -e "


${cblue}Graphicos: Mosaicos$cend"
abat << 'EOH'
for((y=0;y<$[LINES-1];y++));do for((x=0;x<=$COLUMNS;x++));do printf "\e[${y};${x}f\e[38;5;$[232+(x^y)%24]m\u2588";done;done
EOH
  echo -e "


${cblue}Graphics: Math: Fractal de Madelbrot$cend
  Nos acercamos del arte, el autor dejo su firma.
  Copia todo el parafo que sigue:"
  abat << 'EHD'

p=\>\>14 e=echo\ -ne\  S=(S H E L L) I=-16384 t=/tmp/m$$; for x in {1..13}; do \
R=-32768; for y in {1..80}; do B=0 r=0 s=0 j=0 i=0; while [ $((B++)) -lt 32 -a \
$(($s*$j)) -le 1073741824 ];do s=$(($r*$r$p)) j=$(($i*$i$p)) t=$(($s-$j+$R));
i=$(((($r*$i)$p-1)+$I)) r=$t;done;if [ $B -ge 32 ];then $e\ ;else #---::BruXy::-
$e"\E[01;$(((B+3)%8+30))m${S[$((C++%5))]}"; fi;R=$((R+512));done;#----:::(c):::-
$e "\E[m\E(\r\n";I=$((I+1311)); done|tee $t;head -n 12 $t| tac  #-----:2 O 1 O:-
EHD
  echo -e "


${cblue}Graphicos: BaSh on fire$cend
  Reconoces algunos commandos? So todos avanzados.
  "
abat << 'EOH'
X=`tput cols` Y=`tput lines` e=echo M=`eval $e {1..$[X*Y]}` P=`eval $e {1..$X}`;
B=(' ' '\E[0;31m.' '\E[0;31m:' '\E[1;31m+' '\E[0;33m+' '\E[1;33mU' '\E[1;33mW');
$e -e "\E[2J\E[?25l" ; while true; do p=''; for j in  $P; do p=$p$[$RANDOM%2*9];
done;O=${C:0:$[X*(Y-1)]}$p;C='' S='';for p in $M;do #  _-=[ BruXy.RegNet.CZ ]=-_
read a b c d <<< "${O:$[p+X-1]:1} ${O:$[p+X]:1} ${O:$[p+X+1]:1} ${O:$[p+X+X]:1}"
v=$[(a+b+c+d)/4] C=$C$v S=$S${B[$v]}; done; printf "\E[1;1f$S"; done  # (c) 2012
EOH
  echo -e "


${cblue}Graphicos: BaSh on fire$cend
  Dibujos desde la nuve.
  "
abat << 'EOH'
curl -L http://git.io/unix$cend  # UTF8 encoded
curl -L http://artscene.textfiles.com/ansi/scene/am-ice.ans 2> /dev/null | iconv -f cp437 -t utf-8  #  CP-437 encoded
curl -L http://artscene.textfiles.com/ansi/scene/bigtime3.ans 2> /dev/null | iconv -f cp437 -t utf-8
curl -L http://artscene.textfiles.com/ansi/scene/fconfigs.ans 2> /dev/null | iconv -f cp437 -t utf-8
EOH
  echo -e "


${cblue}Graphicos: Enter the matrix$cend"
abat << 'EOH'

echo -e "\e[1;40m" ; clear ; while :; do echo $LINES $COLUMNS $(( $RANDOM % $COLUMNS)) $(( $RANDOM % 72 )) ;sleep 0.05; done|awk '{ letters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"; c=$4; letter=substr(letters,c,1);a[$3]=0;for (x in a) {o=a[x];a[x]=a[x]+1; printf "\033[%s;%sH\033[2;32m%s",o,x,letter; printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,letter;if (a[x] >= $1) { a[x]=0; } }}'

EOH
abat << 'EOH'

(echo -e "\033[2J\033[?25l"; R=`tput lines` C=`tput cols`;: $[R--] ; while true
do ( e=echo\ -e s=sleep j=$[RANDOM%C] d=$[RANDOM%R];for i in `eval $e {1..$R}`;
do c=`printf '\\\\0%o' $[RANDOM%57+33]` ### http://bruxy.regnet.cz/web/linux ###
$e "\033[$[i-1];${j}H\033[32m$c\033[$i;${j}H\033[37m"$c; $s 0.1;if [ $i -ge $d ]
then $e "\033[$[i-d];${j}H ";fi;done;for i in `eval $e {$[i-d]..$R}`; #[mat!rix]
do echo -e "\033[$i;${j}f ";$s 0.1;done)& sleep 0.05;done) #(c) 2011 -- [ BruXy ]
EOH
  echo -e "


${cblue}Fork bomb! No lo corres!$cend
  Te acuerdas de la bomba de fork que llena tus recursos si no usas ${cblue}ulimit$cend?
  Se puede minificar asi:"
abat <<< ':(){:|:&};:'
  echo -e "

$cblue
+----------------+
| Sound to Music |
+----------------+$cend

${cblue}41: Sonido pito$cend"
  abat <<< 'echo -e "\a"'; echo
  echo 'The -e (Escape) is fundamental to enable escape sequence. You can also printf "\a"'
  echo '  Or, after installing sox'
  abat <<< 'play -n synth 0.1 sine 880 vol 0.5'; echo

  echo -e "


${cblue}42: Musica desde el chaos$cend"
abat << 'EHD'
cat /dev/urandom | hexdump -v -e '/1 "%u\\n"' | awk '{ split("0,2,4,5,7,9,11,12",a,","); for (i = 0; i < 1; i+= 0.0001) printf("%08X\\n", 100*sin(1382*exp((a[$1%8+1]/12)*log(2))*i)) }' | xxd -r -p | aplay -c 2 -f S32_LE -r 16000
EHD
  echo -e "


${cblue}Musica 2$cend"
abat <<< 'python3 -c "'
abat python << 'EHD'
while 1:locals().setdefault('t',0);print(chr((((t*((ord('36364689'[t>>13&7])&15)))
//12&128)+(((t>>12)^(t>>12)-2)%11*t//4|t>>13)&127)),end='');t+=1
EHD
abat <<< '" | aplay -r 44100'

  echo -e "


${cblue}Musica 3: Bytebeat From fractal$cend
  Bytebeat (Viznut 2011). Es una forma de generar musica de codigo, basada en la propriedaddes de:
  1/ Fractales
  2/ Bug (overflow y side effect)
  3/ Dicretisacion

  Mira el fractal: \"Triangulo de Sierpinski\" (t&t>>8):
  (Nota que para annular el efecto de retorno a la linea ${cyellow}> setterm -linewrap off$cend or ${cyellow}> tput rmam$cend y ${cyellow}> tput smam$cend para restorar.
  "
abat << 'EHD'
for((y=63;y>0;y-=2));do s="";for((x=64;x--;));do(((x-y/2)&y))&&s+=" "||s+="Δ";done;echo "$s";done
EHD
  echo -e "
  Convertido En sonido, seria:"
abat << 'EHD'
for((t=0;;t++));do((n=(
t&t>>8
), d=n%255,a=d/64,r=(d%64),b=r/8,c=r%8));printf '%b' "\\$a$b$c";done| aplay 
EHD
  echo -e "


${cblue}Musica 3: Bytebeat VizNut 2011$cend
  Esta melodia la llame \"Mysterie trans\".
  "
abat << 'EHD'
for((t=0;;t++));do((n=(
(t>>7|t|t>>6)*10+4*(t&t>>13|t>>6)
), d=n%255,a=d/64,r=(d%64),b=r/8,c=r%8));printf '%b' "\\$a$b$c";done| aplay 
EHD
  echo -e "


${cblue}Musica 4: Corporate Bullshit Generator$cend
  Permanent Link: http://cbsg.sf.net
  Please install ${cblue}libttspico-utils$cend, a better speach generator than ${cblue}espeak$cend
  "
abat << 'EHD'
curl -s http://pasta.phyrama.com:8083/cgi-bin/live.exe    | grep -Eo '^<li>.*</li>' | sed s,\</\\?li\>,,g | shuf -n 1 | tee /dev/stderr | xargs -I foo -0 pico2wave -w /tmp/blah.wav foo; play  /tmp/blah.wav &> /dev/null
EHD
  echo -e "


${cblue}P99: Just Another Perl Hacker$cend
  El climax del codigo: monolinea, elegante, ofuscado, graficos
  Se encuentra con el nombre Perl Japh (wikipedia: https://en.wikipedia.org/wiki/Just_another_Perl_hacker)

  Perl: Practical Extraction and Reporting Language => Un idioma que busca patrones y reporta de forma elegante (el hijo de sed)
  Japh: Just Another Perl Hacker => Una competencia amical de la forma mas elegante de escribir esta misma frase.

  Aqui tu maestro, escribio uno para tu batismo. No lo intentes entender: es magia oscura.
  Paciencia mi aprendiz ...
  "
abat <<< "perl -e '"
abat perl << 'EHD'
use Time::HiRes"usleep";$|=@q=(a..z," ");print"\e[1m\e[31m";$_="hwjdai 5mcn pkiaasea dr";while(s/(..)(.)//){ $_.=$1; $s.=$2 };@w=("$s"=~/./g);while("@w"ne"@e"){$e[$_]eq$w[$_]or$e[$_]=$q[rand@q]for+0..$#w;print"\r@e";usleep+1e5};print"\e[0m\n"
EHD
  abat <<< "'"
  echo -e "


${cblue}End:$cend

  "
}


music_abs(){
  # TODO merge
  # From: https://tldp.org/LDP/abs/html/devref1.html#MUSICSCR
  ti=2000 vl=$'\xc0' z=$'\x80'; ff(){ for t in `seq 0 $ti`
  do test $(( $t % $1 )) = 0 && echo -n $vl || echo -n $z; done; }

  e=`ff 49` g=`ff 41` a=`ff 36` b=`ff 32` c=`ff 30` cis=`ff 29`
  d=`ff 27` e2=`f 24` n=`f 32767`

  echo -n "$g$e2$d$c$d$c$a$g$n$g$e$n$g$e2$d$c$c$b$c$cis$n$cis$d \
  $n$g$e2$d$c$d$c$a$g$n$g$e$n$g$a$d$c$b$a$b$c" | aplay
}


garfield(){
  TODO in tarea
  ANIMATION=https://16colo.rs/pack/acdu1092/raw/BRTRACD2.ANS
  SPEED='.005' # wait this time each line

  # 1. Disable cursor
  printf "\e[?25l"

  # 2. Download, convert, display slow == play animation
  curl --silent $ANIMATION | \
      iconv -f cp437 -t utf-8  | \
      awk "{system(\"sleep $SPEED\");print}"

  # 3. Enable cursor settings
  printf "\e[?12l\e[?25h"
}

more(){
  # Generate random text: http://www.bashoneliners.com/oneliners/199/
  tr -dc a-z1-4 </dev/urandom | tr 1-2 ' \n' | awk 'length==0 || length>50' | tr 3-4 ' ' | sed 's/^ *//' | cat -s | fmt
}

get_fct_dic
call_fct_arg "$@"
