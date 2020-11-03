# TODO
  * 92, 102, 103
  * Rename all linux_intro 00..99
  * Cryptografia de cesar: `echo “Make it right for once and for all” |tr [A-Za-z0-9] [N-ZA-Mn-za-m3-90-2]`
  * Arithmetic: `printf %.10f\\n "$((10**9 * 20/7))e-9"`
  * PS1, PS2, PS3, PS4: Hay una en el control: https://www.thegeekstuff.com/2008/09/bash-shell-take-control-of-ps1-ps2-ps3-ps4-and-prompt_command/
    * https://ss64.com/bash/syntax-prompt.html

## Ideas
  * Tarea: find, grep, hacer la generacion de un sistem de archivos, servir los resultados de stackoverflow

## BigData

* Contact Achal
* Conocimiento avanzado de SQL (técnicas de optimización de querys SQL)
* Python "basico" pero tiene que ser funcional
* Nuve => "No nunca trabaje en la nuve las empresas lo tenian on premise con vpn"




# First week

1. System: File System
2. Syntax: Redirection, Quoting and expansion: Learn about redirection of output and input using > and < and pipes using |. Know > overwrites the output file and >> appends. Learn about stdout and stderr.
  * TODO aprte on virtual file: https://tldp.org/LDP/abs/html/devref1.html
  * random, zero, null
3. System: Users and Machines: whoami, who, w, ip or ifconfig
  * su -,  dig, traceroute, route.
4. Syntax: Job and quotes:
  * OK: Learn about file glob expansion with * (and perhaps ? and [...]) and quoting and the difference between double " and single ' quotes. (See more on variable expansion below.)
  * OK: Be familiar with Bash job management: &, ctrl-z, ctrl-c, jobs, fg, bg, kill, etc.
  * Signal suspend, shutdowmn childdeath ...
  * READ:  trap: http://www.learnlinux.org.za/courses/build/shell-scripting/ch12s03.html
  * Tarea: perfecta trap: https://www.linuxjournal.com/article/10815
5. System: Navigate like a Sailor
  * Obs: Tarea: /dev/null, /dev/random, /dev/zero
  * Obs: Play with urandom and $RANDOM and command interpolation
  * OK: Tarea: free -m, cat /proc/meminfo
  * OK: Tarea: fork bomb: https://www.cyberciti.biz/faq/understanding-bash-fork-bomb/
  * OK: Tarea: ulimit (builtin, con la fork bomb)
  * OK: Tarea: pstree and init
  * OK: Class: Hacer archicos muy grandes (class p16)
  * OK: Class: filter to get all commands seen in clases and apropos
  * OK: Class: ps
  * OK: Class: fork, exec
  * OK: Class: FileSystem playing: https://unix.stackexchange.com/questions/161922/view-physical-location-of-a-file-directory-on-a-hard-disk
  * OK: Tarea: Compile and load a device driver /dev/one that I must code: See links


- First week evaluation:
  - TODO: Interactivo o en paple (voto en papel)
  - https://www.guru99.com/linux-interview-questions-answers.html
  - 20 awesome: https://innolitics.com/articles/advanced-bash-exercises/

# Second Week

6. OK: Syntax: Recreo
  * One liner of death
  * And how to find what: man, apropos in light
  * arecord -f cd - | aplay -  # Tubo de la muerte
  * Pinpon: ((t*5&t>>7)|(t*3&t>>10))&+(+50^-100)%128
7. OK: System: Dev tools
  * OK: Docker,chroot = contenedores (facil)
  * OK: Git, control de version (quasi una sciencia)
  * OK Tarea: Wget, Curl
  * NOT DONE: Tarea: Docker .bashrc, install fortune, cowsay
    * Mande el alumno al quick start de la doc oficial, ya es grande y me queda el 9 entero
  * OK: Tarea: unshare
  * OK: Tarea: Chroot : French class exercices jail break : http://demange.vincent.free.fr/teaching/2012s2l3infosecu/td5_break_chroot.pdf
8. Syntax: Programming
  * OK: Maquina de Turing
  * OK: Turing: Teorema e mo completud
  * OK: Función, Condiciones, Ciclos
  * OK: Expresiones regulares: son muy importantes para los admin y dev ops, hasta para los architectos y jefes
  * OK: Tarea: sobre Regex
  * OK: Tarea: Demo que funciones, jumps
  * TODO: Tarea, 3 tareas sobre ciclo, funcion y rama
9. System: Servidor
  * OK: Class: explicar bien daemon == servicio
  * OK: 1/ Python: Network filesystem
  * 2/ Cgi: Php
  * 3/ Jenkins
10. Final: Lenguaje: Colección
  * OK: Table de idiomas de que vamos a hablar
  * OK: BlaBla: Assemby, Rust, Java, Ruby
  * OK: Javascript
  * OK: Stackoverflow survey: https://insights.stackoverflow.com/survey/2020#technology-programming-scripting-and-markup-languages
  * TODO tipeo, fuerte, debil
  * Python
  * Perl
  * C
  * Tarea: Php
  * Tareas: Sql (StackOverflow)

- Bonus 1:
  * Process start
  * Computar start
  * Fast: Class: Nano, Vim 3 modos, Emacs or text editor, choose your weapon
  * Compilator workflow, or interpreter (Raku and Javascript/WebAssembly)

- Ideas:
  * Virtualisation, VirtualBox verus Docker. Que es virtual que es real? En realidad es todo virtual pero bue. Entonces virtual significa Mas virtual
  * Monitoring (performance and load)
  * Encoding, utf8, hex (4 bits), octal, binario, ASCII, 16 bits
  * Idea: Penetration testing con nmap, openssl



# Links

### Meta
  * Link in terminal: https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda

### Clase 5: Procesos y Dispositivos
  * Porque no functiona shred en SSD: https://askubuntu.com/questions/794612/how-to-securely-wipe-files-from-ssd-drive
  * fileshred: https://unix.stackexchange.com/questions/161922/view-physical-location-of-a-file-directory-on-a-hard-disk
  * fileshred: https://unix.stackexchange.com/questions/514135/getting-sector-number-from-inode-or-address-space-mapping
  * Create a device driver: https://www.apriorit.com/dev-blog/195-simple-driver-for-linux-os
  * Device driver pdf: http://studenti.fisica.unifi.it/~carla/manuali/linux_device_driver_tutorial.pdf
  * Ver mknod
  * Ring -3 .. 3: https://medium.com/swlh/negative-rings-in-intel-architecture-the-security-threats-youve-probably-never-heard-of-d725a4b6f831


### Clase 6: Monolinea
  * Abierto, con votos: http://www.bashoneliners.com/oneliners/popular/
  * Jugar con 100 archivo (fome per instructivo): http://www.npcharrier.com/unix/bash-one-liner/
  * Print 10, impresive: https://bruxy.regnet.cz/web/linux/EN/useless-bash/https://bruxy.regnet.cz/web/linux/EN/useless-bash/
  * Composing music: https://blog.robertelder.org/bash-one-liner-compose-music/
  * Super bash, Linux cheat sheet: https://bruxy.regnet.cz/web/linux/EN/bash-cheat-sheet/ (from Guru)
  * Music BruXy Good reference: https://bruxy.regnet.cz/web/linux/EN/linux-demoscene/
  * Music, with beep: https://github.com/NaWer/beep/
  * Article on one liner music: http://countercomplex.blogspot.com/2011/10/some-deep-analysis-of-one-line-music.html 2011
  * Stdin Buffering problem: http://www.pixelbeat.org/programming/stdio_buffering/
  * TTS: https://askubuntu.com/questions/501910/how-to-text-to-speech-output-using-command-line
  * Viznut awesome blog: http://viznut.fi/en/
  * Github topic: One-liner: https://github.com/topics/one-liners
  * Bytebeat collection: http://wry.me/toys/bytebeat/examples.html
  * Bytebeat Lines: faster retrieval: https://www.reddit.com/r/bytebeat/comments/20km9l/cool_equations/
  * ByteBeat : Html5 : Github : Greggman : https://github.com/greggman/html5bytebeat
  * Bytebeat : Text list: https://github.com/feilipu/avrfreertos/blob/master/GoldilocksAnalogue/music_formula_collection.txt
  * ByteBeat : Pdf : https://nightmachines.tv/downloads/Bytebeats_Beginners_Guide_TTNM_v1-5.pdf
  * ByteBeat : Full music Hexagon: https://github.com/Qqwy/ExtremeBytebeats


### Clase 7: Herramientas Docker y Git
  * Chroot : French class exercices jail break : http://demange.vincent.free.fr/teaching/2012s2l3infosecu/td5_break_chroot.pdf
  * Chroot : Tutorial largo : https://www.howtogeek.com/441534/how-to-use-the-chroot-command-on-linux/
  * Busybox : List of Unix command : https://en.wikipedia.org/wiki/List_of_Unix_commands
  * Sandobox : First name I encountered (2011): https://www2.dmst.aueb.gr/dds/pubs/conf/2001-Freenix-Sandbox/html/sandbox32final.pdf
  * Sandbox : FireJail : In Linux Many approach : https://www.opensourceforu.com/2016/07/many-approaches-sandboxing-linux/
  * Sandbox : Seccomp :  Full Description : https://blog.cloudflare.com/sandboxing-in-linux-with-zero-lines-of-code/
  * Docker namespaces : https://stackoverflow.com/questions/46450341/chroot-vs-docker
  * Docker : Doc : Get-Started : https://docs.docker.com/get-started/
  * Docker tutorial Long : https://docker-curriculum.com/
  * Markdown descripcion rapida (cheatsheet): https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet
  * Markdown para progradores: https://github.github.com/gfm/
  * Github : Advanced search doc : https://docs.github.com/en/free-pro-team@latest/github/searching-for-information-on-github/searching-issues-and-pull-requests
  * Git: Practical Easy : Init : https://opensource.com/article/19/5/practical-learning-exercise-git
  * Git: Practical: Ultra interactiveo: 23 (demasiado largo): https://gitexercises.fracz.com/
  * Git exericice: Training material pure text, many ideas: https://training-course-material.com/training/Git_exercises
  * HIt interactive and online: (my choice):  https://learngitbranching.js.org/
  * Wget: 20 commands: https://www.labnol.org/software/wget-command-examples/28750/
  * Domain example: http://example.com/
  * Git: easy class, starting by init, white bg pages: https://www.rithmschool.com/courses/git/git-github-git-basics-exercises
  * Big website example: https://wiki.bash-hackers.org/syntax/basicgrammar


### Clase 8: Common programming, Regex
  * Expreciones regulares, cuantificacion, agrupacion, alternacion: https://es.wikipedia.org/wiki/Expresi%C3%B3n_regular
  * Ejercicios BaSh: https://dccn-hpc-wiki.readthedocs.io/en/latest/docs/bash/exercise_programming.html
  * Ejercicios Shell: Collection: Muchos en frances: https://ineumann.developpez.com/tutoriels/linux/exercices-shell/
  * Historia: First function in 1945: https://en.wikipedia.org/wiki/Subroutine#History
  * Tarea: Regex : exelente juego : http://regextutorials.com/excercise.html?Floating%20point%20numbers
  * Tarea: Regex: French class: http://www.ww.exelib.net/linux/les-expressions-regulieres-regex.html
  * Tarea: Regex: Easy some examples: https://code-maven.com/slides/perl/exercise-regular-expressions
  * Tarea: Loop: https://linuxhint.com/bash-for-loop-examples/

  * Djistra: Single return point : https://softwareengineering.stackexchange.com/questions/118703/where-did-the-notion-of-one-return-only-come-from
  * Turing machine Ex: https://github.com/forsooth/Turing-Machine
  * Historia de informatica : En 5 generaciones : https://apen.es/2019/08/29/historia-de-la-informatica/


### Clase 9: Servicio y servidor
  * Web terminal: https://anyterm.org/
  * Web terminal (good) (it is called HTTP TTY): https://github.com/yudai/gotty
  * Bash HTTP navigator (untested): https://gist.github.com/upperstream/b9b77429bc024541b7605aea76086ad8
  * Bash HTTP navigator (tested, Abach): https://github.com/moshe/abache/blob/master/abache
  * Miniwal web server using netcat: https://stackoverflow.com/questions/16640054/minimal-web-server-using-netcat
  * Bash get with nc: https://unix.stackexchange.com/questions/336876/simple-shell-script-to-send-socket-message
  * Bash get: https://gist.github.com/jadell/871512
  * Netcat HTTPS (with openssl): https://serverfault.com/questions/102032/connecting-to-https-with-netcat-nc
  * ToWiki: netcat sending message: https://superuser.com/questions/98089/sending-file-via-netcat
  * HTTP Server list (like rosetta code): https://gist.github.com/willurd/5720255
  * Roseta echo server: https://rosettacode.org/wiki/Echo_server#Raku
  * ROseta HTTP Get: https://rosettacode.org/wiki/HTTP#Raku
  * Nginx hello world (i used): https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04



### Clase 10: Language zoo
  * Paradigmos : https://en.wikipedia.org/wiki/Programming_paradigm
  * Js Fast code for Web console: https://www.digitalocean.com/community/tutorials/how-to-use-the-javascript-developer-console
  * VHDL: ex: http://www.asic-world.com/vhdl/first1.html
  * VHDL Compile: http://ghdl.free.fr/ghdl/The-hello-word-program.html
  * VHDL Reference (my) : https://www.ics.uci.edu/~jmoorkan/vhdlref/for_loop.html
  * Tarea: FLow control ex: http://parallel.vub.ac.be/documentation/linux/unixdoc_download/exercises/Scripts.Ex.html



### Clase 11: Data analisys, the old way
  * https://downloads.dataiku.com/public/website-additional-assets/data/orders.csv
