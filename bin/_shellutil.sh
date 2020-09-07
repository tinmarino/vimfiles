#!/usr/bin/env bash
# Implement Shell utilities to hide the misery
#
# Warning: cannot be sourced in main bashrc it will polute the declared functions
#
# shellcheck disable=SC2155  # Declare and assign separately to avoid masking return values
# shellcheck disable=SC2092  # Remove backticks
# shellcheck disable=SC2178  # Variable was used as an array but is now assigned a string
#

default_usage(){
  `# Print this message`
  #print_title "Default Usage"
  msg="${cblue}Usage:$cend $(basename "$0") [options] function

  ${cblue}Default Option list:
  --------------------$cend
    -h | --help           Print (this) help and exit

  ${cblue}Function list:
  --------------$cend
  "
  echo -ne "$msg" | sed -e 's/^[[:space:]]\{2\}//'
  print_fct_usage; echo
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
  # shellcheck disable=SC2068
  for item in ${pre_fct[@]}; do
    # shellcheck disable=SC2206  # Quote
    #local_fct=( [${post_fct[@]//${i}}]="" )
    # Replace item
    tps=("${tps[@]/$item}")
  done
  tps=("${tps[@]//}")
  # shellcheck disable=SC2206
  local_fct=("${tps[@]}")

  # Get functions docstring
  # shellcheck disable=SC2068
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

print_fct_usage(){
  `# Echo functon description`
  `# :param1: <ref> function dictionary <- get_fct_dic`
  `# short version`
  format="${1:-short}"
  # shellcheck disable=SC2207  # Prefer mapfile
  IFS=$'\n' sorted_fct=($(sort <<<"${!fct_dic[*]}"))
  # shellcheck disable=SC2068  # Double quote
  if [[ "$format" == "complete" ]]; then
    for fct in ${sorted_fct[@]}; do
      COMPREPLY+=("$fct $line")
      read -r line < <(echo "${fct_dic[$fct]}")
      line=$(eval echo "\"$line\"")
      echo "$fct - $line"
      #printf ">$cpurple%-13s$cend%s\n" "${fct#_}" "$line"
    done
  elif [[ "$format" == "short" ]]; then
    for fct in ${sorted_fct[@]}; do
      read -r line < <(echo "${fct_dic[$fct]}")
      line=$(eval echo "\"$line\"")
      printf "$cpurple%-13s$cend$line\n" "${fct#_}"
    done
  else
    for fct in ${sorted_fct[@]}; do
      echo -e "$cpurple${fct#_}$cend"
      while read -r line; do
        line=$(eval echo "\"$line\"")
        echo "  $line"
      done < <(echo "${fct_dic[$fct]}")
      echo
    done
  fi
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

call_fct_arg(){
  `# Call function from trailing arguments (after options)`
  `# :param1: <ref> argumet array`
  declare -n l_args=$1

  # Clause: Do not work without argument
  if [[ -z "${l_args[*]}" ]]; then
    switch_usage;
    exit 0;
  fi

  local b_is_subcommand=0
  set -- "${l_args[@]}"
  for arg in "$@"; do
    shift
    # shellcheck disable=SC2076  # Don't quote right-hand side of =
    if [[ "complete" == "$arg" ]]; then
      print_fct_usage "complete"
      break
    elif ((b_is_subcommand)); then
      break
    elif [[ "-h" == "$arg" || "--help" == "$arg"  || "help" == "$arg" \
        || "usage" == "$arg" || "_usage" == "$arg" ]]; then
      switch_usage;
      exit 0;
    elif [[ " ${!fct_dic[*]} " =~ " $arg " ]]; then
      b_is_subcommand=1
      # shellcheck disable=SC2068  # Double quote array
      "$arg" $@  # ${l_args[@]}
    elif [[ " ${!fct_dic[*]} " =~ " _$arg " ]]; then
      b_is_subcommand=1
      # shellcheck disable=SC2068  # Double quote array
      "_$arg" $@  # ${l_args[@]}
    else
      echo -e "${cred}ERROR: ShellUtil: $0: unknown argument: $arg => Ciao!"
      exit "$error_arg"
    fi
  done
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
  `# Echo: script starting => for log and debug`
  echo -e "${cgreen}-------------------------------------------------"
  echo -e "IrmJenkins: $0: Starting at: $(date "+%Y-%m-%dT%H:%M:%S")"
  echo -e "-------------------------------------------------$cend"
}

print_n_run(){
  `# Print and run command passed as array reference`
  declare -n l_cmd=$1
  # Note: The "${var@Q}" expansion quotes the variable such that it can be parsed back by bash. Since bash 4.4: 17 Sep 2016
  # -- ALMA has Bash 4.2: 2011
  # -- Link: https://stackoverflow.com/questions/12985178
  res=0
  echo -e "${cyellow}IrmJenkins: $0: Running: $(printf "'%s' " "${l_cmd[@]}")  # at $(date "+%Y-%m-%dT%H:%M:%S")$cend"
  ((b_run)) && { eval "${l_cmd[@]}"; res=$?; }
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

# shellcheck disable=SC2034  # ... appears unused
if can_color $@; then
  cend="\e[0m"             # Normal
  cpurple="\e[38;5;135m"   # Titles
  cblue="\e[38;5;39m"      # Bold
  cgreen="\e[38;5;34m"     # Ok
  cred="\e[38;5;124m"      # Error
  cyellow="\e[38;5;229m"   # Code
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
