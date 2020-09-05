#!/usr/bin/env bash
# shellcheck disable=SC2092  # Remove backticks

source "$(dirname "$0")/_shellutil.sh"
declare -a pre_fct=$(declare -F -p | cut -d " " -f 3)

usage(){
  msg="Tinmarino documentation
    Usage: $0 function

  ${cblue}Function list:
  --------------$cend
  "
  echo -ne "$msg" | sed -e 's/^[[:space:]]\{2\}//'
  print_fct_usage fct_dic
}

_sed() {
  `# Print sed command info`
  info sed "Command and Option Index" | \
    sed -n '/\*/s/ s c/ s \(substitute\) c/;s/command[:,].*//p'
  echo 'w Sed  # for my wiki file'
}

declare -A fct_dic
get_fct_dic fct_dic pre_fct

# Argument Parsing
# ################

# Clause: Work only if at least one argument
if [[ $# -eq 0 ]] ; then usage; exit 0; fi

options=$(getopt \
  -l "help,print" \
  -o "hp" -- "$@")

eval set -- "$options"
while true; do
  case "$1" in
    (-h|--help) usage; exit 0
      ;;
    (--)
      shift
      break
      ;;
  esac
  shift
done
echo

# shellcheck disable=SC2034  # Unsued
declare -a args=("$@")
call_fct_arg fct_dic args
