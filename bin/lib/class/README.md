# First week

1. System: File System
2. Syntax: Redirection, Quoting and expansion: Learn about redirection of output and input using > and < and pipes using |. Know > overwrites the output file and >> appends. Learn about stdout and stderr.
  * TODO aprte on virtual file: https://tldp.org/LDP/abs/html/devref1.html
  * random, zero, null
3. System: Users and Machines: whoami, who, w, ip or ifconfig
  * su -,  dig, traceroute, route.
4. Syntax: Job and quotes:
  * OK: Learn about file glob expansion with * (and perhaps ? and [...]) and quoting and the difference between double " and single ' quotes. (See more on variable expansion below.)
  * Be familiar with Bash job management: &, ctrl-z, ctrl-c, jobs, fg, bg, kill, etc.
  * Signal suspend, shutdowmn childdeath ...
  * OK: Tarea: filter to get all commands seen in clases and apropos
  * READ:  trap: http://www.learnlinux.org.za/courses/build/shell-scripting/ch12s03.html
  * Tarea: prrfecta trap: https://www.linuxjournal.com/article/10815
5. System: Navigate like a Sailor
  * ps
  * fork, exec
  * ulimit
  * Tarea: Niceness: nice, renice
  * Tarea: fork bomb: https://www.cyberciti.biz/faq/understanding-bash-fork-bomb/
  * Tarea: find, grep, hacer la generacion de un sistem de archivos
  * Tarea: pstree and init
  * Tarea: /dev/null, /dev/random, /dev/zero
  * Tarea: FileSystem playing: https://unix.stackexchange.com/questions/161922/view-physical-location-of-a-file-directory-on-a-hard-disk
  * Tarea: Compile and load a device driver /dev/one that I must code: See links

- First week evaluation:
  - https://www.guru99.com/linux-interview-questions-answers.html
  - 20 awesome: https://innolitics.com/articles/advanced-bash-exercises/

# Second Week

6. Syntax: Recreo
  * One liner of death, And how to find what: man, apropos in light
7. System: Dev tootls
  *  Wget, Curl, Git and ... Vim or Nano, Emacs or text editor, choose your weapon
8. Syntax: Programming
  * Macina de Turing
  * Turing: Teorema e mo completud
  * BlaBla: https://insights.stackoverflow.com/survey/2020#technology-programming-scripting-and-markup-languages
  * BlaBla: Assemby, Rust, Java, Ruby
  * Function
  * Branches
  * Ciclos
  * Python
  * Perl
  * Javascript
  * C
  * Tarea: Php
  * Tareas: Sql
9. System: Servidor
  * email postfix, emap
  * 1/ Python: Network filesystem
  * 2/ Cgi: Php
  * 3/ Jenkins
  * Servidor jenkins
  * Tarea: cron
  * Idea: Web hosting, servidor web, apagche, nginx, ver capitulo 19
10. Final: Los pequenios "detailles"
  * Trap
  * Virtualisation, VirtualBox verus Docker. Que es virtual que es real? En realidad es todo virtual pero bue. Entonces virtual significa Mas virtual
  * Monitoring (performance and load)
  * Encoding, utf8, hex (4 bits), octal, binario, ASCII, 16 bits
  * Idea: Penetration testing con nmap, openssl

- Second week evaluation:




# Links

### Clase 5: Procesos y Dispositivos
  * Porque no functiona shred en SSD: https://askubuntu.com/questions/794612/how-to-securely-wipe-files-from-ssd-drive
  * fileshred: https://unix.stackexchange.com/questions/161922/view-physical-location-of-a-file-directory-on-a-hard-disk
  * fileshred: https://unix.stackexchange.com/questions/514135/getting-sector-number-from-inode-or-address-space-mapping
  * Create a device driver: https://www.apriorit.com/dev-blog/195-simple-driver-for-linux-os
  * Device driver pdf: http://studenti.fisica.unifi.it/~carla/manuali/linux_device_driver_tutorial.pdf
  * Ver mknod
