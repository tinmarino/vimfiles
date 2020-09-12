#!/usr/bin/env bash
# Shell utilities to hide the misery
#
# Warning: cannot be sourced in main bashrc it will polute the declared functions
#

default_usage(){
  `# Print this usage message`
  print_usage_common
}


bin_path(){
  `# Print path of bin`
  dirname "${BASH_SOURCE[0]}"
}

get_fct_dic(){
  `# Get associative array of functions in calling script`
  `# :param1: <ref_out> associative array name`
  `# :param2: <ref_in> array of functions already defined`
  declare -a post_fct=$(declare -F -p | cut -d " " -f 3)
  local nl=$'\n'

  # Purge funtions defined before
  # See copy: https://stackoverflow.com/questions/19417015/how-to-copy-an-array-in-bash
  # See delete: https://stackoverflow.com/questions/16860877/remove-an-element-from-a-bash-array
  tps=("${post_fct[@]}")
  # shellcheck disable=SC2068  # Use quotes
  for item in ${pre_fct[@]}; do
    # Replace item
    tps=("${tps[@]/$item}")
  done
  tps=("${tps[@]//}")
  local_fct=("${tps[@]}")

  # Get functions docstring
  # shellcheck disable=SC2068  # Use quotes
  for fct in ${local_fct[@]}; do
    # Clause: Hide function starting with `__`
    [[ "${fct:0:2}" == "__" ]] && continue

    description=""
    while read -r line; do
      # Pass: if head
      [[ "$line" =~ ^$fct ]] && continue
      # Pass: if first open bracket
      [[ "${line:0:1}" == '{' ]] && continue
      # Stop: if not an inline comment
      [[ "${line:0:2}" == '`#' ]] || break
      # Purge head and tail and concat
      [[ "$description" == "" ]] \
        && description+="${line:3:-2}" \
        || description+="$nl${line:3:-2}"
    done < <(typeset -f "$fct")
    # Append to dic
    fct_dic["$fct"]="$description"
  done
}

print_usage_fct(){
  `# Echo functon description`
  `# :param1: format <string>: short, long`
  `# :param2: type <string>: option, function`
  `# short version`
  local format="${1:-short}"
  local typee="${2:-function}"
  # shellcheck disable=SC2207  # Prefer mapfile
  IFS=$'\n' sorted_fct=($(sort <<<"${!fct_dic[*]}"))
  # shellcheck disable=SC2068  # Double quote
  for fct in ${sorted_fct[@]}; do
    arg="$fct"
    # Clause: Pass -h, --help and set_env
    if [[ "${fct}" == "set_env" ]]; then
      continue
    fi
    if [[ "${fct:0:3}" == "mm_" ]]; then
      if [[ "$typee" == "option" ]]; then
        arg="--${fct:3}"
      else
        continue
      fi
    fi
    if [[ "${fct:0:2}" == "m_" ]]; then
      if [[ "$typee" == "option" ]]; then
        arg="--${fct:2}"
      else
        continue
      fi
    fi
    if [[ "$typee" == "option" ]] \
        && [[ "${fct:0:2}" != "m_"  && "${fct:0:3}" != "mm_" ]]; then
      continue
    fi

    if [[ "$format" == "complete" ]]; then
      COMPREPLY+=("$fct $line")
      read -r line < <(echo "${fct_dic[$fct]}")
      line=$(eval echo "\"$line\"")
      echo "$arg - $line"
      #printf ">$cpurple%-13s$cend%s\n" "${fct#_}" "$line"
    elif [[ "$format" == "short" ]]; then
      read -r line < <(echo "${fct_dic[$fct]}")
      line=$(eval echo "\"$line\"")
      printf "$cpurple%-13s$cend  $line\n" "${arg}"
    else
      echo -e "$cpurple${fct#_}$cend"
      while read -r line; do
        line=$(eval echo "\"$line\"")
        echo "  $line"
      done < <(echo "${fct_dic[$fct]}")
      echo
    fi
  done
}

call_fct_arg(){
  `# Call function from trailing arguments (after options)`
  `# :param1: <ref> argumet array`
  # Clause: Do not work without argument
  if [[ -z "$*" ]]; then
    switch_usage;
  fi

  local b_is_subcommand=0
  for arg in "$@"; do
    shift
    # shellcheck disable=SC2076  # Don't quote right-hand side of =
    if [[ "complete" == "$arg" ]]; then
      print_usage_fct "complete"
      break
    elif ((b_is_subcommand)); then
      break
    elif [[ "-h" == "$arg" || "--help" == "$arg"  || "help" == "$arg" \
        || "usage" == "$arg" || "_usage" == "$arg" ]]; then
      switch_usage
      exit 0;
    elif [[ "-p" == "$arg" || "--print" == "$arg" ]] ; then
      set_print
    elif [[ "${arg:0:2}" == "--" ]] \
        && fct="${arg:2}" && fct="mm_${fct//-/_}" \
        && [[ " ${!fct_dic[*]} " =~ " $fct " ]]; then
      "$fct" "$@"
    elif [[ "${arg:0:1}" == "-" && " ${!fct_dic[*]} " =~ " m_$arg " ]]; then
      "m_$arg" "$@"
    elif [[ " ${!fct_dic[*]} " =~ " $arg " ]]; then
      b_is_subcommand=1
      "$arg" "$@"
    elif [[ " ${!fct_dic[*]} " =~ " _$arg " ]]; then
      b_is_subcommand=1
      "_$arg" "$@"
    else
      echo -e "${cred}ERROR: ShellUtil: $0: unknown argument: $arg => Ciao!"
      exit "$error_arg"
    fi
  done
}

register_subcommand(){
  `# Register a sub command`
  `# Used for function call and completion`
  fct="$1"
  file="$2"
  description=$(awk 'NR == 2' "$file")
  # Purge head and tail
  description="${description:3:-2}"
  # Append to dictionaries
  fct_dic["$fct"]="$description"
  cmd_dic["$fct"]="$file"
}

print_usage_env(){
  `# Print Environment varaibles used`
  # shellcheck disable=SC2034  # set_env appears unused
  typeset -f set_env | awk -v cpurple="\\$cpurple" -v cend="\\$cend" '
    BEGIN { FS=":=" }
    /:/ {
      gsub("^ *: *\"\\$\\{|\\}\";$", "", $0) ;
      slen=20-length($1); if(slen < 2) slen=2 ;
      s=sprintf("%-*s", slen , " ");
      gsub(/ /,"-",s);
      printf("%s%s%s  %s  %s\n", cpurple, $1, cend, s, $2);
    }
  '
}

print_usage_common(){
  `# Print Usage Tail: Fct, Option, Env`
  msg="${cblue}Usage:$cend ${cpurple}$(basename "$0")$cend [options] function"

  list="$(print_usage_fct)"
  [[ -n "$list" ]] && msg+="
  ${cblue}Function list:
  --------------$cend
  $list
  "

  list="$(print_usage_fct short option)"
  [[ -n "$list" ]] && msg+="
  ${cblue}Option list:
  ------------$cend
  $list
  "

  list="$(print_usage_env)"
  [[ -n "$list" ]] && msg+="
  ${cblue}Environment variable:
  ---------------------$cend
  $list
  "

  echo -ne "$msg" | sed -e 's/^[[:space:]]\{2\}//'
}

switch_usage(){
  `# Switch Call: usage, _usage or default_usage`
  if declare -F usage; then
    usage;
    elif declare -F _usage; then
    _usage
  else
    default_usage
  fi
}

can_color(){
  `# Test if stdoutput supports color`
  if command -v tput > /dev/null \
      && tput colors > /dev/null \
      && [[ "$1" != 'complete' ]] ; then
    return 0
  else
    return 1
  fi
}

print_script_start(){
  `# Echo: script starting => for log`
  start_time=$(date +%s)
  echo -e "${cgreen}--------------------------------------------------------"
  echo -e "ShellUtil: $(basename "$0"): Starting at: $(date "+%Y-%m-%dT%H:%M:%S")"
  echo -e "--------------------------------------------------------$cend"
}

print_script_end(){
  `# Echo: script ending + time elapsed => for log`
  # Calcultate time
  local end_time=$(date +%s)
  local sec_time=$((end_time - start_time))
  printf -v script_time '%dh:%dm:%ds' $((sec_time/3600)) $((sec_time%3600/60)) $((sec_time%60))
  echo -e "${cgreen}------------------------------------------------------"
  echo -e "ShellUtil: $(basename "$0"): Ending at: $(date "+%Y-%m-%dT%H:%M:%S")$cend"
  echo -e "  # After: $script_time"
  echo -e "${cgreen}------------------------------------------------------$cend"
}

print_n_run(){
  `# Print and run command passed as array reference`
  # Note: The "${var@Q}" expansion quotes the variable such that it can be parsed back by bash. Since bash 4.4: 17 Sep 2016
  # -- ALMA has Bash 4.2: 2011
  # -- Link: https://stackoverflow.com/questions/12985178
  res=0
  echo -e "${cpurple}ShellUtil: $(basename "$0"): Running:$cend ${cyellow}$(printf "'%s' " "$@")$cend"
  echo -e "  # at $(date "+%Y-%m-%dT%H:%M:%S") in $PWD"
  ((b_run)) && { eval "$@"; res=$?; }
  return $res
}

print_title(){
  `# Link: https://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash`
  color=${2:-$cpurple}
  chrlen=${#1}
  echo -e "${color}$1"
  eval printf '%.0s-' "{1..$chrlen}"
  echo -e "$cend"
}

set_print(){
  `# Set do not run => only print command`
  b_run=0
}


shellutil_main(){
  `# Main function`
  if can_color "$@"; then
    cend="\e[0m"             # Normal
    cpurple="\e[38;5;135m"   # Titles
    cblue="\e[38;5;39m"      # Bold
    cgreen="\e[38;5;34m"     # Ok
    cred="\e[38;5;124m"      # Error
    cyellow="\e[38;5;229m"   # Code
  elif false; then
    cend="\e[0m"       # Normal
    cred="\e[31m"      # Error
    cgreen="\e[32m"    # Ok
    cyellow="\e[33m"   # Code
    cblue="\e[34m"     # Bold
    cpurple="\e[35m"   # Titles
  else
    cend=""
    cpurple=""
    cblue=""
    cgreen=""
    cred=""
  fi
  
  # Path here
  # shellcheck disable=SC2034  # bin_path appears unused
  bin_path=$(bin_path)
  
  # Error values
  # shellcheck disable=SC2034
  error_cd=2
  error_arg=3
  
  # By default, run commands
  b_run=1

  # Register caller functions
  declare -a pre_fct=$(declare -F -p | cut -d " " -f 3)
  declare -A fct_dic
  declare -A cmd_dic
}

shellutil_main "$@"

# vim:sw=2:ts=2:
