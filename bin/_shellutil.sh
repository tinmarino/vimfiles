#!/usr/bin/env bash
# Shell utilities to hide the misery
#
# shellcheck disable=SC2155  # Declare and assign separately to avoid masking return values
# shellcheck disable=SC2092  # Remove backticks
# shellcheck disable=SC2178  # Variable was used as an array but is now assigned a string
#

get_root(){
  `# Echo path of the IrmJenkins project`
  script_rel="$(dirname "${BASH_SOURCE[0]}")"
  script_abs="$(realpath "$script_rel")"
  root_path="$(realpath "$script_abs/..")"
  echo "$root_path"
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
      description+="${line:3:-2}$nl"
      # Debug: TODO remove
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
  declare -n l_fct_dic=$1
  # shellcheck disable=SC2207  # Prefer mapfile
  IFS=$'\n' sorted_fct=($(sort <<<"${local_fct[*]}"))
  # shellcheck disable=SC2068  # Double quote
  for fct in ${sorted_fct[@]}; do
    echo -e "$cpurple$fct$cend"
    while read -r line; do
      echo "  $line"
    done < <(echo "${l_fct_dic[$fct]}")
  done
}

print_script_start(){
  `# Echo: script starting => for log and debug`
  echo -e "${cgreen}-------------------------------------------------"
  echo -e "IrmJenkins: $0: Starting at: $(date "+%Y-%m-%dT%H:%M:%S")"
  echo -e "-------------------------------------------------$cend"
}

print_n_run(){
  `# Print adn run command passed as array reference`
  declare -n l_cmd=$1
  # Note: The "${var@Q}" expansion quotes the variable such that it can be parsed back by bash. Since bash 4.4: 17 Sep 2016
  # -- ALMA has Bash 4.2: 2011
  # -- Link: https://stackoverflow.com/questions/12985178
  res=0
  echo -e "${cyellow}IrmJenkins: $0: Running: $(printf "'%s' " "${l_cmd[@]}")  # at $(date "+%Y-%m-%dT%H:%M:%S")$cend"
  ((b_run)) && { eval "${l_cmd[@]}"; res=$?; }
  return $res
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
  for arg in $l_args; do
    # shellcheck disable=SC2076  # Don't quote right-hand side of =
    if [[ " ${!l_fct_dic[*]} " =~ " $arg " ]]; then
      echo
      echo -e "${cpurple}IrmJenkins: $0: Calling: $arg"
      echo -e "-------------------------------------------------$cend"
      $arg
    else
      echo
      echo -e "${cred}ERROR: IrmJenkins: $0: unknown argument: $arg => Ciao!"
      echo -e "-------------------------------------------------$cend"
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

# Error values
# shellcheck disable=SC2034
error_cd=2
error_arg=3

# By default, run commands
b_run=1
