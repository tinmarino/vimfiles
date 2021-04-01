#!/usr/bin/env bash
# -- Tarea: df, du y misc
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../shellutil.sh"

__usage(){
  local msg="$cblue
+==================+
|  File System Bis |
+==================+$cend

${cblue}P01: CoPy (CP)$cend
  ${cyellow}> cd ~/Test$cend
  ${cyellow}> touch test1.txt$cend
  ${cyellow}> cp test1.txt test_new.txt$cend

${cblue}P01: Disk Format (DF)$cend
  ${cyellow}> df$cend
  ${cyellow}> df -m$cend
  Cual es la diferencia?
  ${cyellow}> man df$cend
  Presiona 'q' (como Quit) para salir

${cblue}P02: Disk Usage (DU)$cend
  ${cyellow}> du .$cend
  ${cyellow}> du ~$cend

${cblue}P03: CHange MODe (CHMOD)$cend
  ${cyellow}> echo 'echo Message from the file' > script.sh$cend
  ${cyellow}> ls -l$cend
  ${cyellow}> ./script.sh$cend
  ${cyellow}> chmod +x ./script.sh$cend
  'x' como eXecute, que cambio este commando?

${cblue}P04: CHange OWNer (CHOWN)$cend
  ${cyellow}> chown root:root ./script.sh$cend
  ${cyellow}> ls -l$cend
  ${cyellow}> ./script.sh$cend
  ${cyellow}> chown jim:jim ./script.sh$cend
  jim:jim significa usario jim y grupo jim. Que es la diferencia entre usario y grupo?

${cblue}P05: Your Name (UNAME)$cend
  ${cyellow}> uname -a$cend

${cblue}P06: Host Name (HOSNAME)$cend
  ${cyellow}> hostname$cend
  ${cyellow}> hostname -I$cend

${cblue}P07: Ping (PING)$cend
  ${cyellow}> ping www.google.com$cend
  Tienes acceso a internet?
  Que puerto usa el ping? El HTTP? El HTTPS? Porque diferentes puertos?


${cblue}End$cend
  Felicitacion, para ir mas lejos:
  - Description of an inode
  - mount, fdisk, mkfs, lsblk
"

  echo -e "$msg"
}

__void(){
  local cmt="
    TODO: 20 commands here: https://maker.pro/linux/tutorial/basic-linux-commands-for-beginners
    TOOD: More and in link: https://github.com/jlevy/the-art-of-command-line

    0:53 Tech Phone screens
    1:50 How to check the kernel version of a Linux system?
    2:50 How to see the current IP address on Linux?
    4:03 How to check for free disk space in Linux?
    4:55 How to see if a Linux service is running?
    6:33 How to check the size of a directory in Linux?
    7:02 How to check for open ports in Linux?
    9:48 How to check Linux process information [CPU usage, memory, user information, etc.]?
    11:49 How to deal with mounts in Linux
    13:51 Man pages
    15:04 Other resources
  "
  echo "$cmt"
}

get_fct_dic
call_fct_arg "$@"
