#!/usr/bin/env bash
# Print documentation on command, utils, self-scripts
# shellcheck disable=SC2092  # Remove backticks

source "$(dirname "$0")/_shellutil.sh"
declare -a pre_fct=$(declare -F -p | cut -d " " -f 3)

_usage(){
  `# Print this message`
  print_title "Tinmarino Documentation"
  msg="${cblue}Usage:$cend $0 function

  ${cblue}Function list:
  --------------$cend
  "
  echo -ne "$msg" | sed -e 's/^[[:space:]]\{2\}//'
  print_fct_usage fct_dic; echo
}

_sed(){
  `# Print Stream EDitor command info`
  print_title "SED: Stream EDitor"
  info sed "Command and Option Index" | \
    sed -n '/\*/s/ s c/ s \(substitute\) c/;s/command[:,].*//p'
  echo; echo 'w Sed  # for my wiki file'; echo
}

_color(){
  `# Print Ansi Escape color list colorized`
  `# Long string`
  "$(dirname "$0")/tin_color_256_show.sh"
}

_tin_command(){
  `# Print description of all commands in current directory"`
  for cmd in $(ls -p | grep -v /); do
    desc=$(awk 'NR == 2' "$cmd")
    desc=${desc###}; desc=${desc## }
    printf "$cpurple%-25s$cend%s\n" "$cmd" "$desc"
  done
}

declare -A fct_dic
get_fct_dic fct_dic pre_fct

# Argument Parsing
# ################

# Clause: Work only if at least one argument
if [[ $# -eq 0 ]] ; then _usage; exit 0; fi

options=$(getopt \
  -l "help" \
  -o "h" -- "$@")

eval set -- "$options"
while true; do
  case "$1" in
    (-h|--help) _usage; exit 0;;
    (--) shift; break;;
  esac
  shift
done

# shellcheck disable=SC2034  # Unsued
declare -a args=("$@")
call_fct_arg fct_dic args
