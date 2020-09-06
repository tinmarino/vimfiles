#!/usr/bin/env bash
# Implement Shell utilities to hide the misery
#
# shellcheck disable=SC2155  # Declare and assign separately to avoid masking return values
# shellcheck disable=SC2092  # Remove backticks
# shellcheck disable=SC2178  # Variable was used as an array but is now assigned a string
#

bin_path(){
  `# Print path of bin`
  echo "$(dirname "${BASH_SOURCE[0]}")"
}

get_fct_dic(){
  `# Get associative array of functions in calling script`
  `# :param1: <ref_out> associative array name`
  `# :param2: <ref_in> array of functions already defined`
  declare -n l_fct_dic=$1
  declare -n l_pre_fct=$2
  declare -a post_fct=$(declare -F -p | cut -d " " -f 3)
  local nl=$'\n'


  # Purge funtions defined before
  tps=" ${post_fct[*]} "
  # shellcheck disable=SC2068
  for item in ${l_pre_fct[@]}; do
    # shellcheck disable=SC2206  # Quote
    #local_fct=( [${post_fct[@]//${i}}]="" )
    # Replace item
    tps=${tps//${item}}
  done
  # shellcheck disable=SC2206
  local_fct=( $tps )

  # Get functions docstring
  # shellcheck disable=SC2068
  for fct in ${local_fct[@]}; do
    description=""
    while read -r line; do
      # Pass: if head
      [[ "$line" =~ ^$fct ]] && continue
      [[ "$line" =~ \{ ]] && continue
      # Stop: if not an inline comment
      [[ "$line" =~ ^\`\# ]] || break
      # Append to dic
      [[ "$description" == "" ]] \
        && description+="${line:3:-2}" \
        || description+="$nl${line:3:-2}"
    done < <(typeset -f "$fct")
    # shellcheck disable=SC2034  # l_fct_dic appears unused <= it is a reference
    l_fct_dic["$fct"]="$description"
  done
}

can_color(){
  `# Test if stdoutput supports color`
  if command -v tput > /dev/null && tput colors > /dev/null ; then
    return 0
  else
    return 1
  fi
}

print_fct_usage(){
  `# Echo functon description`
  `# :param1: <ref> function dictionary <- get_fct_dic`
  `# short version`
  declare -n l_fct_dic=$1
  format="${2:-short}"
  # shellcheck disable=SC2207  # Prefer mapfile
  IFS=$'\n' sorted_fct=($(sort <<<"${local_fct[*]}"))
  # shellcheck disable=SC2068  # Double quote
  if [[ "$format" == "short" ]]; then
    for fct in ${sorted_fct[@]}; do
      read -r line < <(echo "${l_fct_dic[$fct]}")
      printf "$cpurple%-13s$cend%s\n" "${fct#_}" "$line"
    done
  else
    for fct in ${sorted_fct[@]}; do
      echo -e "$cpurple${fct#_}$cend"
      while read -r line; do
        echo "  $line"
      done < <(echo "${l_fct_dic[$fct]}")
      echo
    done
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
  eval printf '%.0s-' {1..$chrlen}
  echo -e "$cend"
}

set_print(){
  `# Set do not run => only print command`
  b_run=0
}

call_fct_arg(){
  `# Call function from trailing arguments (after options)`
  `# :param1: <ref> fct_dic`
  `# :param2: <ref> argumet array`
  declare -n l_fct_dic=$1
  declare -n l_args=$2
  for arg in "${l_args[@]}"; do
    # shellcheck disable=SC2076  # Don't quote right-hand side of =
    if [[ " ${!l_fct_dic[*]} " =~ " $arg " ]]; then
      "$arg"
    elif [[ " ${!l_fct_dic[*]} " =~ " _$arg " ]]; then
      "_$arg"
    else
      echo -e "${cred}ERROR: ShellUtil: $0: unknown argument: $arg => Ciao!"
      exit "$error_arg"
    fi
  done
}


# shellcheck disable=SC2034  # ... appears unused
if can_color; then
  cend="\e[0m"
  cpurple="\e[38;5;135m"
  cblue="\e[38;5;39m"
  cgreen="\e[38;5;34m"
  cred="\e[38;5;124m"
  cyellow="\e[38;5;229m"
else
  cend=""
  cpurple=""
  cblue=""
  cgreen=""
  cred=""
fi

# Path here
bin_path=$(bin_path)

# Error values
# shellcheck disable=SC2034
error_cd=2
error_arg=3

# By default, run commands
b_run=1
