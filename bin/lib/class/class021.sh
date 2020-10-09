#!/usr/bin/env bash
# ${cblue}Clase 021$cend: Redirecion, Citas y expanciones
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  local msg="$cblue
+===============+
|  Redirections |
+===============+$cend

a/ Acuerdate: En Linux, todo es archivo!
b/ En Linux existe lo que se llama ${cblue}descriptores de archivos$cend o (file descriptor o simplemente fd para los intimos van de 0 a 9). Acuerdate que empezamos a contar de 0 como para las cuadras
c/ Los 3 primeros son importantes:
  - fd 0: StdIn: la entrada estandar de un commando
  - fd 1: StdOut: la salida estandar de un commando
  - fd 2: StdErr: el error estandar de un commando. Suele ser usado para los humanos. No cunfundir con el codigo de retorno
d/ Cada commando retorna un numero entre 0 y 255 (en un byte no mas como en 1970). Si este numero es 0 es que el commando ha sido existoso, sino es que fallo. Y con eso ya empezamos a programmar: Si fallo: haga eso, sino: hago eso lo que se llama ramas (branches). Y si agregamos ciclos (loop) tenemos todo de un idioma Turing complete. Lo que es BaSh

Gracias por leer,
Vamos!


${cblue}P01: Escribe a la salida estandar (ECHO)$cend
  ${cyellow}> echo un texto cualquiera$cend
  ${cyellow}> echo 'un texto cualquiera'$cend
  ${cyellow}> echo \"un texto cualquiera\"$cend

${cblue}P02: Interpolacion de variables (\$)$cend
  La diferencia entre la simple cita ' y la doble \" es que el la doble, hay interpolacion de variable.
  Nota que no hay espacio alrededor del operador =
  Nota que BaSh es muy sencible a los espacios: separan el commando de los argumentos, los argumentos entre si, los commandos entre si, los 'token' (como >, |, <, o &)
  Ya que tengo espacio en el contenido de la variable, tengo que ponerle unas citas
  ${cyellow}> var=\"contenido de la variable\"$cend
  ${cyellow}> echo Eso es mi \$var$cend
  ${cyellow}> echo \"Eso es mi \$var\"$cend
  ${cyellow}> echo 'Pero vez, eso no es mi \$var'$cend

  El \$var no se expende con el valor del variable con los las citas simple ${cblue}single quote$cend. La comillas simple dan al comando el texto como es.
  Que pasa si no pongo en commilla?

  ${cyellow}> var=contenido de la variable$cend

  Porque?

${cblue}P03: Redirecion de salida (>)$cend
  Escribir en la terminal esta bien, pero es el arenero, los grandes deben escribir en otras cosas: RAN, Archivos, Puertos, Pantalla, Otros terminales, y sabes que todos esos son archivos.
  ${cyellow}> content=\"Line 1\\nLine 2\\nLine 3\\nLine 4\\nLine 5\\n\"$cend
  ${cyellow}> echo \$content > new_file.txt$cend
  Pero cuidado, eso bora el contenido previo de file_new.txt.

  Para borar un arvhivo, hay un modismo que usa el commando llamado Nop para No OPeracion, ese es \":\"
  ${cyellow}> : > new_file.txt$cend
  Se borro !

${cblue}P04: Redirecion de salida en agragacion (>>)$cend
  Para agregar, usa el dobe >>
  ${cyellow}> : >> new_file.txt$cend
  ${cyellow}> echo \$content >> new_file.txt$cend
  ${cyellow}> echo \$content >> new_file.txt$cend
  ${cyellow}> cat new_file.txt$cend

${cblue}P05: Redirecion entrada (<)$cend
  > cat < new_file.txt
  > sed 's/Line/Otra Wea/' < new_file.txt

  La uso muy poco porque en general los commandos acceptan nombre de archivo como argumentos (por eso no deben tener espacios).
  En general, es commun remplacar una redirection de salida con un cat en un tubo ...

${cblue}P06: Tubo (|)$cend
  El tubo redirige la salida de un comando en la entrada de uno
  ${cyellow}> $cat -$cend  # Permite escribir la entrada en la salida (basicamente no hace nada, como \":\")
  ${cyellow}> tee file_in_pipe.txt$cend  # Duplica su entrada en el archivo file_in_pipe.txt y en su salida estandar

  ${cyellow}> jim class021 top_tag  # Muestra los primeros tag de StackOverflow$cend
  ${cyellow}> jim class021 top_tag | grep -v '^ *#'$cend
  ${cyellow}> jim class021 top_tag | grep -v '^ *#' | grep -v '^ *$'$cend
  ${cyellow}> jim class021 top_tag | grep -v '^ *#' | grep -v '^ *$' | sort -n -k 2$cend
  ${cyellow}> jim class021 top_tag | grep -v '^ *#' | grep -v '^ *$' | sort -n -k 2 | head -n 20$cend
  ${cyellow}> jim class021 top_tag | grep -v '^ *#' | grep -v '^ *$' | sort -n -k 2 | head -n 20 > language_mas_populares.txt$cend


${cblue}P07: StdErr A ver juntos$cend


${cblue}End$cend

Felicaitacion de nuevo suegrito!
Los tubos son geniales, te voy a dar trabajo en casa.
${cred}Tu mejor amigo en man$cend


"

  echo -e "$msg"
}


top_tag(){
  msg="
# Aqui sigue los 200 tag que tienen el mejor rango en el sito  
# Corrido en https://data.stackexchange.com/stackoverflow/query/edit/1307361
# Con el codigo SQL siguidente:
#   select 
#          num.TagName as Tag,
#          row_number() over (order by rate.Rate desc) as MayRank,
#          row_number() over (order by num.Num desc) as TotalRank,
#          rate.Rate as QuestionsInMay,
#          num.Num as QuestionsTotal
#   
#   from
#   
#   (select count(PostId) as Rate, TagName
#   from
#     Tags, PostTags, Posts
#   where Tags.Id = PostTags.TagId and Posts.Id = PostId
#   group by TagName) as rate
#   
#   INNER JOIN
#   
#   (select count(PostId) as Num, TagName
#   from
#     Tags, PostTags, Posts
#   where Tags.Id = PostTags.TagId and Posts.Id = PostId
#   group by TagName
#   having count(PostId) > 800)
#   as num ON rate.TagName = num.TagName
#   order by rate.rate desc
#   ;

# Tag            TotalRank  Questions
database             40   172266
numpy                83   80705
ajax                 34   211950
algorithm            60   102978
iphone               32   220691
wcf                  140  50119
google-chrome        104  64820
asp.net-mvc-4        167  42268
oop                  128  53777
validation           114  60802
xcode                46   145679
nginx                160  43815
spring-boot          69   91880
html                 7    1025424
shell                86   79266
css                  10   686068
asynchronous         168  42124
file                 95   71673
datetime             120  56894
unit-testing         94   72051
firebase             64   100081
security             136  51287
forms                58   103528
azure                67   94172
sql                  13   561864
heroku               192  37262
function             74   87841
cocoa                182  39070
rest                 84   80137
machine-learning     163  42662
macos                61   102874
typescript           51   128203
recursion            187  38430
hibernate            79   84942
gradle               178  40189
git                  53   126771
web-services         116  59980
oracle               52   126823
spring-mvc           124  54587
wordpress            42   168603
join                 195  36948
windows              47   144902
spring               39   175827
android              6    1301614
laravel              44   158109
uitableview          110  62620
templates            146  47834
javascript           1    2097175
date                 105  64408
jenkins              166  42536
xamarin              161  43623
session              165  42550
haskell              155  44844
c++                  9    694064
ubuntu               138  51137
jquery               8    998308
twitter-bootstrap    65   99511
jsp                  135  51351
amazon-web-services  59   103400
elasticsearch        150  46809
django               28   246598
web                  175  40827
dart                 185  38677
android-fragments    162  43119
curl                 183  38904
tensorflow           111  62427
qt                   89   77047
exception            191  37267
perl                 102  65655
linux                36   196200
magento              188  37835
symfony              101  67026
mongodb              48   137481
sorting              106  64322
asp.net-mvc-3        186  38569
winforms             70   90398
csv                  93   72802
opencv               117  59612
sql-server-2008      129  53639
actionscript-3       170  41328
jpa                  159  43863
dictionary           119  57836
listview             139  50333
entity-framework     76   85340
vb.net               49   131583
python-2.7           68   93975
react-native         75   85772
asp.net-mvc          37   191825
post                 199  36643
unix                 157  44120
firefox              200  36619
json                 20   302622
matplotlib           131  52317
arrays               17   343297
ssl                  156  44144
maven                91   76051
performance          71   90257
vue.js               103  65631
python-3.x           26   253794
ruby-on-rails        19   320998
google-app-engine    154  45308
wpf                  43   158793
class                99   67669
unity3d              127  53863
facebook             81   84815
github               176  40605
xml                  35   196917
ruby-on-rails-3      123  55972
testing              172  41003
if-statement         143  49158
tomcat               177  40493
c++11                132  52290
android-layout       122  56072
jquery-ui            181  39319
go                   142  49187
ionic-framework      174  40852
regex                31   232841
cordova              113  60919
python               3    1549298
php                  5    1373149
visual-studio        66   98491
ggplot2              194  37048
for-loop             125  54271
flutter              112  62098
vba                  38   180125
batch-file           144  48846
linq                 85   79656
sql-server           22   293091
pdf                  158  44101
c                    18   340696
apache-spark         109  63329
string               45   157419
eclipse              56   120820
inheritance          189  37402
xaml                 121  56675
parsing              137  51237
asp.net-core         134  51964
laravel-5            190  37350
angularjs            25   261520
selenium             87   79219
matlab               72   88781
debugging            153  45745
delphi               151  46619
.net                 21   301712
.htaccess            98   68588
reactjs              27   250091
authentication       147  47545
ios                  11   641652
redirect             198  36772
sqlite               80   84859
loops                92   75736
swing                90   76698
sockets              115  60252
multithreading       54   125666
ruby                 33   215701
http                 118  59423
visual-studio-2010   149  46897
image                62   101980
internet-explorer    184  38802
ms-access            133  52170
list                 57   107262
variables            148  46965
hadoop               164  42586
math                 197  36795
user-interface       141  50066
api                  82   83400
asp.net              15   359232
flask                171  41122
email                126  54054
node.js              16   352798
dataframe            88   78467
c#                   4    1439002
java                 2    1717945
tsql                 107  63991
objective-c          23   290712
postgresql           55   125139
bash                 50   129010
pointers             145  48598
winapi               196  36847
animation            179  39601
express              97   69333
r                    14   367319
docker               78   85157
android-studio       96   71600
apache               73   87982
excel                29   234329
generics             169  42088
kotlin               152  46602
object               130  53174
amazon-s3            193  37207
powershell           77   85285
mysql                12   608470
angular              30   233414
pandas               41   171941
google-maps          108  63347
selenium-webdriver   173  40883
scala                63   100633
swift                24   279236
url                  180  39429
codeigniter          100  67307
"

  echo "$msg"
}


__void(){
  local cmt="
  Learn about redirection of output and input using > and < and pipes using |. Know > overwrites the output file and >> appends. Learn about stdout and stderr.
  "
  echo "$cmt"
}

get_fct_dic
call_fct_arg "$@"
