#!/usr/bin/env bash
# ${cblue}Clase 012$cend: Trabajo en casa sobre el systema de archivos
#
# shellcheck disable=SC2154  # cblue is referenced but not

source "$(dirname "${BASH_SOURCE[0]}")/../../_shellutil.sh"

__usage(){
  msg="$cblue
========================+
|  File System Homework |
========================+$cend


${cblue}Homework 1: Moving FIle and directory and yourself$cend

${cblue}P01:$cend Create a simple text file with the following console commands:
  ${cyellow}> touch simple_file.txt$cend
  ${cyellow}> echo \"Ejemplo de archivo de texto\\npara el curso de Linux\" > simple_file.txt$cend

${cblue}P02:$cend Create two directories with the Linux command mkdir
  ${cyellow}> mkdir txt$cend
  ${cyellow}> mkdir log$cend

${cblue}P03:$cend Copy simple_file.txt into txt directory
  ${cyellow}> cp simple_file.txt txt$cend

${cblue}P04:$cend Rename simple_file.txt to simple_file.log with the Linux command mv
  ${cyellow}> mv simple_file.txt simple_file.log$cend

${cblue}P05:$cend Move simple_file.log to the log directory
  ${cyellow}> mv simple_file.log log$cend

${cblue}P06:$cend List files of the directories txt and log with the command ls
  ${cyellow}> ls txt log$cend

${cblue}P07:$cend Create a new directory named local
  ${cyellow}> mkdir local$cend

${cblue}P08:$cend Move files of directories txt and log into local directory
  ${cyellow}> mv txt/simple_file.txt local$cend
  ${cyellow}> mv log/simple_file.log local$cend

${cblue}P09:$cend Delete directories txt and log
  ${cyellow}> rm -rf txt$cend
  ${cyellow}> rm -rf log$cend

${cblue}P10:$cend List the current directory with command ls
  ${cyellow}> ls$cend

${cblue}P11:$cend List directory local
  ${cyellow}> ls local$cend


${cblue}Homework 2: basic edit files and running scripts$cend

${cblue}P11:$cend Creating first script in bash
    nano primer_script.sh
    Add the following lines to the file.

    ${cyellow}#!/bin/bash

    echo 'Hola Mundo'$cend

    Save the file (pressing control-s to save and control-x to exit)
    Ctrl-s Ctrl-x

    Run the script (comment about the output of the script execution)
    ${cyellow}bash primer_script.sh$cend
  "
  echo -e "$msg"
}

get_fct_dic
call_fct_arg "$@"
