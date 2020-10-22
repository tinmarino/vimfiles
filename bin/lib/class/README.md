# TODO

* play with redirection and pipes
* GUI vs CLI
* Archivo con puntos hidden
* Systema de examen:
  * interactivo Y en papel (Como --doc)
* Missing from last clases
  * TODO Tarea: Niceness: nice, renice
  * TODO Tarea: find, grep, hacer la generacion de un sistem de archivos

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

6. Syntax: Recreo
  * One liner of death
  * And how to find what: man, apropos in light
  * arecord -f cd - | aplay -  # Tubo de la muerte
  * Pinpon: ((t*5&t>>7)|(t*3&t>>10))&+(+50^-100)%128
7. System: Dev tools
  * Docker,chroot = contenedores (facil)
  * Git, control de version (quasi una sciencia)
  * .bashrc, install fortune, cowsay 
  * Class: Nano, Vim 3 modos, Emacs or text editor, choose your weapon
  * Tarea: Wget, Curl
  * Tarea: Chroot : French class exercices jail break : http://demange.vincent.free.fr/teaching/2012s2l3infosecu/td5_break_chroot.pdf
8. Syntax: Programming
  * Expreciones regulares: son muy importantes para los admin y dev ops, hasta para los architectos y jefes
  * Maquina de Turing
  * Turing: Teorema e mo completud
  * BlaBla: https://insights.stackoverflow.com/survey/2020#technology-programming-scripting-and-markup-languages
  * Function
  * Branches
  * Ciclos
  * Tarea: sobre Regex
  * Tarea: Demo que funciones, explicacion punto unico de salida y jumps
9. System: Servidor
  * email postfix, emap
  * Class: explicar bien daemon == servicio
  * 1/ Python: Network filesystem
  * 2/ Cgi: Php
  * 3/ Jenkins
  * Servidor jenkins
  * Tarea: cron
  * Idea: Web hosting, servidor web, apagche, nginx, ver capitulo 19
10. Final: Language: Collecion
  * BlaBla: Assemby, Rust, Java, Ruby
  * Table de idiomas de que vamos a hablar
  * Python
  * Perl
  * Javascript
  * C
  * Tarea: Php
  * Tareas: Sql
  * Virtualisation, VirtualBox verus Docker. Que es virtual que es real? En realidad es todo virtual pero bue. Entonces virtual significa Mas virtual
  * Monitoring (performance and load)
  * Encoding, utf8, hex (4 bits), octal, binario, ASCII, 16 bits
  * Idea: Penetration testing con nmap, openssl

- Second week evaluation:



# Note


# Links

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
  * MUsic BruXy Good reference: https://bruxy.regnet.cz/web/linux/EN/linux-demoscene/
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


### Clase 8: Common programming, Regex


### Clase 9:


### Clase 10: Language zoo
  * Paradigmos : https://en.wikipedia.org/wiki/Programming_paradigm
