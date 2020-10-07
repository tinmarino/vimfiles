#!/usr/bin/env bash
# Shell utilities to hide the misery
#
# shellcheck disable=SC2076  # Don't quote right-hand side of =

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  # If not sourced, prepare to display functions defined here
  declare -a pre_fct=$(typeset -F -p | cut -d " " -f 3)
fi

default_usage(){
  `# Print this usage message`
  `# :param1: format: long, short (default:short)`
  `# :param2: title: (default \$0)`
  local format="${1:-short}"
  local main_file="$0"
  local title="${2:-$main_file}"
  local indent="${3:-0}"

  if [[ "$format" == "short" ]]; then
    # Short
    # Title
    print_title "$title" "" "$indent"

    # Description
    local desc=$(get_file_header "$main_file" long)
    printf "%${indent}s$desc\n\n"

    # Usage
    print_usage_common "$format" "" "$indent"
  else
    # Long

    # The subcommand description is printed earlier by caller
    if [[ "$indent" == 0 ]]; then
      # Title
      print_title "$title" "" "$indent"
      # Description
      local desc=$(get_file_header "$main_file" long)
      printf "%${indent}s$desc\n\n"
    fi

    print_usage_common "$format" "" "$indent"
    ((next_indent=indent+2))
    # shellcheck disable=SC2207  # Prefer mapfile
    IFS=$'\n' sorted_cmd=($(sort <<<"${!cmd_dic[*]}"))
    # shellcheck disable=SC2068  # Double quote
    for cmd in ${sorted_cmd[@]}; do
      local file="${cmd_dic[$cmd]}"
      local desc=$(get_file_header "$file" long)
      echo; echo
      # Title
      print_title "$cmd" "" "$indent"

      # Description
      printf "%${indent}s$desc\n\n"

      # Sub call
      "$0" "$cmd" "--doc" "$next_indent"
    done
  fi
}

get_file_header(){
  `# Read first line of scritp to retrieve it header`
  `# :param1: filename`
  `# :param2: format long or short`
  local file="$1"
  local format="${2:-short}"

  local desc="$file"
  local awk_cmd='NR == 2'

  if [[ ! "$format" == "short" ]]; then
    awk_cmd='/^$|^[^#]|^#\s*$/{exit}; NR>=2{print}'
  fi

  desc=$(awk "$awk_cmd" "$file" | sed -e 's/^# *//')
  desc=$(eval "echo \"$desc\"")
  echo "$desc"
}

get_fct_dic(){
  `# Get associative array of functions declared in calling script`
  `# -- -> fct_dic (internal and used in call_fct_arg`
  declare -a post_fct=$(typeset -F -p | cut -d " " -f 3)
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

  # Append --print and --help
  fct_dic['mm_help']='Print this message'
  fct_dic['mm_print']='Only print command instead of executing'
  fct_dic['mm_doc']='Print documentation (longer than help)'
}

print_usage_fct(){
  `# Echo functon description`
  `# :param1: format <string>: short, long`
  `# :param2: type <string>: option, function`
  `# :param3: indent <int>`
  local format="${1:-short}"
  local typee="${2:-function}"
  local indent="${3:-0}"

  if [[ "$format" == "complete" ]]; then
    # Supposing array is given as argument number 4 to caller command
    # From: https://stackoverflow.com/questions/17879322/how-do-i-autocomplete-nested-multi-level-subcommands
    ARG_TAIL=("${@:5}")
    ((index=1))
    subcmd=UNFOUND
    while ((index >= 0)); do
      subcmd=${ARG_TAIL[index]}
      [[ "${subcmd:0:1}" != "-" ]] && break
      ((index++))
    done

    if [[ ${COMP_CWORD} -ge 2 ]]; then
      if [[ -n "$subcmd" ]] && [[ " ${!cmd_dic[*]} " =~ " $subcmd " ]]; then
        cmd="${cmd_dic["$subcmd"]}"
        local res=$("$cmd" complete "$2" "$3" "$4" "${ARG_TAIL[@]:index}")
        echo -ne "$res"
        return
      elif [[ " ${!fct_dic[*]} " =~ " $subcmd " ]]; then
        return
      fi
    fi
  else
    # Must be set here otherwise, ignoring null byte in input
    local s_indent="$(printf "%${indent}s" "")"
  fi

  # shellcheck disable=SC2207  # Prefer mapfile
  IFS=$'\n' sorted_fct=($(sort <<<"${!fct_dic[*]}"))
  # shellcheck disable=SC2068  # Double quote
  for fct in ${sorted_fct[@]}; do
    arg="$fct"
    # Clause: Pass -h, --help and __set_env
    if [[ "${fct}" == "__set_env" ]]; then
      continue
    fi
    if [[ "${fct:0:3}" == "mm_" ]]; then
      if [[ "$typee" == "option" || "$format" == "complete" ]]; then
        arg="--${fct:3}"
      else
        continue
      fi
    fi
    if [[ "${fct:0:2}" == "m_" ]]; then
      if [[ "$typee" == "option" || "$format" == "complete" ]]; then
        arg="--${fct:2}"
      else
        continue
      fi
    fi
    if [[ "${fct:0:1}" == "_" ]]; then
      # Removes _ prefix
      arg="${fct:1}"
    fi
    if [[ "$typee" == "option" ]] \
        && [[ "${fct:0:2}" != "m_"  && "${fct:0:3}" != "mm_" ]]; then
      continue
    fi

    if [[ "$format" == "complete" ]]; then
      # Complete
      read -r line < <(echo "${fct_dic[$fct]}")
      line=$(eval echo "\"$line\"")
      echo "$arg : $line"
    elif [[ "$format" == "short" ]]; then
      # Short
      read -r line < <(echo "${fct_dic[$fct]}")
      line=$(eval echo "\"$line\"")
      printf "${s_indent}$cpurple%-13s$cend  $line\n" "${arg}"
    else
      # Long
      echo -e "$s_indent$cpurple${arg}$cend"
      while read -r line; do
        line=$(eval echo "\"$line\"")
        echo -e "$s_indent$line"
      done < <(echo "${fct_dic[$fct]}")
      echo
    fi
  done
}

call_fct_arg(){
  `# Call function with trailing arguments (after options)`
  local res=0;

  # Clause: Do not work without argument
  args="$*"
  if [[ -z "$*" ]]; then
    switch_usage short
  fi

  # Init
  # shellcheck disable=SC2034  # set_env appears unused
  if [[ -n "${args[*]}" ]] && \
      [[ ! " ${args[*]} " =~ " complete " &&  ! " ${args[*]} " =~ " --doc " ]] && \
      typeset -F __at_init > /dev/null; then
    __at_init "$@";
  fi

  # Call argument
  local b_is_subcommand=0
  for arg in "$@"; do
    shift
    if [[ "complete" == "$arg" ]]; then
      print_usage_fct "complete" "$@"
      break
    elif ((b_is_subcommand)); then
      break
    elif [[ " ${!cmd_dic[*]} " =~ " $arg " ]]; then
      # If registered as subcommand
      b_is_subcommand=1
      cmd="${cmd_dic["$arg"]}"
      "$cmd" "$@"
    elif [[ "-h" == "$arg" || "--help" == "$arg"  || "help" == "$arg" \
        || "usage" == "$arg" || "_usage" == "$arg" ]]; then
      switch_usage short
      exit 0;
    elif [[ "--doc" == "$arg" ]]; then
      # shellcheck disable=SC2034  # set_env appears unused
      if typeset -f __doc > /dev/null; then
        __doc long "" "$1"
      else
        switch_usage long "" "$1"
      fi
      exit 0;
    elif [[ "-p" == "$arg" || "--print" == "$arg" ]] ; then
      set_print
    elif [[ "${arg:0:2}" == "--" ]] \
        && fct="${arg:2}" && fct="mm_${fct//-/_}" \
        && [[ " ${!fct_dic[*]} " =~ " $fct " ]]; then
      ((b_is_subcommand=1))
      "$fct" "$@"; ((res+=$?))
    elif [[ "${arg:0:1}" == "-" && " ${!fct_dic[*]} " =~ " m_$arg " ]]; then
      ((b_is_subcommand=1))
      "m_$arg" "$@"; ((res+=$?))
    elif [[ " ${!fct_dic[*]} " =~ " $arg " ]]; then
      echo -e "${cpurple}IrmJenkins: $(basename "$0"): Calling Function: $arg"
      echo -e "-------------------------------------------------$cend"
      ((b_is_subcommand=1))
      "$arg" "$@"; ((res+=$?))
    elif [[ " ${!fct_dic[*]} " =~ " _$arg " ]]; then
      echo -e "${cpurple}IrmJenkins: $(basename "$0"): Calling Function: $arg"
      echo -e "-------------------------------------------------$cend"
      ((b_is_subcommand=1))
      "_$arg" "$@"; ((res+=$?))
    else
      echo -e "${cred}ERROR: IrmJenkins: $(basename "$0"): unknown argument: $arg => Ciao!"
      echo -e "-------------------------------------------------$cend"
      exit "$E_ARG"
    fi
  done

  # Finish
  # shellcheck disable=SC2034  # set_env appears unused
  if [[ -n "${args[*]}" ]] && [[ ! " ${args[*]} " =~ " complete " ]] && typeset -F __at_finish > /dev/null; then
    __at_finish "$@"; ((res+=$?))
  fi

  # Return
  return "$res"
}

dispatch(){
  `# Util: get_fct_dic and call function`
  get_fct_dic
  call_fct_arg "$@"
}

register_subcommand(){
  `# Register a sub command`
  `# Used for function call and completion`
  fct="$1"
  file="$2"
  description=$(awk 'NR == 2' "$file")
  # Purge head and tail
  description="${description:2}"
  # Append to dictionaries
  fct_dic["$fct"]="$description"
  cmd_dic["$fct"]="$file"
}

print_usage_env(){
  `# Print Environment variables used`
  `# -- That is why they must be set in __set_env`
  `# :param3: indent`
  local indent="${3:=0}"
  local s_indent="$(printf "%${indent}s" "")"

  # shellcheck disable=SC2034  # set_env appears unused
  typeset -f __set_env | awk -v cpurple="\\$cpurple" -v cend="\\$cend" -v s_indent="$s_indent" '
    BEGIN { FS=":=" }
    /:/ {
      gsub("^ *: *\"\\$\\{|\\}\";$", "", $0) ;
      slen=20-length($1); if(slen < 2) slen=2 ;
      s=sprintf("%-*s", slen , " ");
      gsub(/ /,"-",s);
      printf("%s%s%s%s  %s  %s\n", s_indent, cpurple, $1, cend, s, $2);
    }
  '
}

print_usage_common(){
  `# Print Usage Tail: Fct, Option, Env`
  `# :param1: format`
  `# :param2: title`
  `# :param3: indent`
  local format="${1:=short}"
  local indent="${3:=0}"
  local s_indent="$(printf "%${indent}s" "")"

  # Usage
  local msg="${s_indent}${cblue}Usage:$cend ${cpurple}$(basename "$0")$cend [options] function\n"

  # Function
  local list="$(print_usage_fct "$format" "" "$indent")"
  if [[ -n "$list" ]]; then
    msg+="${s_indent}${cblue}Function list:\n"
    msg+="${s_indent}--------------$cend\n"
    msg+="$list\n\n"
  fi

  # Option
  local list="$(print_usage_fct "$format" option "$indent")"
  if [[ -n "$list" ]]; then
    msg+="${s_indent}${cblue}Option list:\n"
    msg+="${s_indent}------------$cend\n"
    msg+="$list\n\n"
  fi

  # Environment
  local list="$(print_usage_env "$format" "" "$indent")"
  if [[ -n "$list" ]]; then
    msg+="${s_indent}${cblue}Environment variable:\n"
    msg+="${s_indent}---------------------$cend\n"
    msg+="$list\n\n"
  fi

  # Return
  echo -ne "$msg"
}

switch_usage(){
  `# Switch Call: usage, _usage or default_usage`
  `# :param1: format: short or long`
  `# :param2: title <str>`
  `# :param3: indent <int>`
  # shellcheck disable=SC2034  # __usage appears unused
  if typeset -F __usage > /dev/null; then
    __usage "$1" "$2" "$3";
  elif typeset -F __doc > /dev/null; then
    __doc "$1" "$2" "$3";
  else
    default_usage "$1" "$2" "$3"
  fi
}

can_color(){
  `# Test if stdoutput supports color`
  `# (Mostly for internal use)`
  if command -v tput > /dev/null \
      && tput colors > /dev/null \
      && [[ "$1" != 'complete' ]] ; then
    return 0
  else
    return 1
  fi
}

print_script_start(){
  `# Print: script starting => for log`
  start_time=$(date +%s)
  echo -e "${cgreen}--------------------------------------------------------"
  echo -e "$PROJECT_NAME: $(basename "$0"): Starting $* at: $(date "+%Y-%m-%dT%H:%M:%S")"
  echo -e "--------------------------------------------------------$cend"
}

print_script_end(){
  `# Print: script ending + time elapsed => for log`
  # Calcultate time
  local end_time=$(date +%s)
  local sec_time=$((end_time - start_time))
  printf -v script_time '%dh:%dm:%ds' $((sec_time/3600)) $((sec_time%3600/60)) $((sec_time%60))
  echo -e "${cgreen}------------------------------------------------------"
  echo -e "$PROJECT_NAME: $(basename "$0"): Ending at: $(date "+%Y-%m-%dT%H:%M:%S")$cend"
  echo -e "  # After: $script_time"
  echo -e "${cgreen}------------------------------------------------------$cend"
}

print_n_run(){
  `# Print and run command passed as array reference`
  local res=0
  # Unquote special bash symbols
  # Note: The "${var@Q}" expansion quotes the variable such that it can be parsed back by bash. Since bash 4.4: 17 Sep 2016
  # -- ALMA has Bash 4.2: 2011
  # -- Link: https://stackoverflow.com/questions/12985178
  local cmd=$(printf "'%s' " "$@" | \
    sed -e "s/'|'/|/g" | \
    sed -e "s/'>'/>/g" | \
    sed -e "s/'<'/</g" | \
    sed -e "s/'&&'/\&\&/g" | \
    sed -e "s/'||'/||/g" | \
    sed -e "s/'2>&1'/2>\&1/g" | \
    cat
  )
  echo -e "${cpurple}IrmJenkins: $(basename "$0"): Running:$cend $cyellow$cmd$cend"
  echo -e "      # in '$PWD' at $(date "+%Y-%m-%dT%H:%M:%S")"
  ((b_run)) && { eval "$@"; res=$?; }
  return $res
}

print_title(){
  `# Print string and underline`
  `# :param1: [Required] title to print`
  `# :param2: color or prefix to print (default purple)`
  `# :param3: <int> indentation level (default 0)`
  # Link: https://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash
  chrlen=${#1}
  color=${2:-$cpurple}
  indent="${3:-0}"

  # First line
  printf "%${indent}s" ""
  echo -e "${color}$1"

  # Subtitle
  printf "%${indent}s" ""
  eval printf '%.0s-' "{1..$chrlen}"

  # End colorize
  echo -e "$cend"
}

set_print(){
  `# Set option: do not run => only print command`
  b_run=0
}

bin_path(){
  `# Print path of bin`
  dirname "${BASH_SOURCE[0]}"
}

shellutil_main(){
  `# Main code: embeded in function for fold`
  `# Keep me last!`
  PROJECT_NAME=ShellUtil

  # Gruvbox: https://github.com/alacritty/alacritty/wiki/Color-schemes#gruvbox
  if can_color "$@"; then
    cend="\e[0m"             # Normal
    cpurple="\e[38;5;135m"   # Titles
    cblue="\e[38;5;39m"      # Bold, Info
    cgreen="\e[38;5;34m"     # Ok
    cred="\e[38;5;124m"      # Error
    # Changed the yellow to orange so can be seen on whit bg
    cyellow="\e[1m\e[38;5;208m"   # Code
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
  # shellcheck disable=SC2034  # Unused variable
  E_CD=82        # Cannot change directory => does it exists, are env var ok ?
  E_ARG=83       # Bad arguments given => read usage
  # shellcheck disable=SC2034  # Unused variable
  E_USER=84      # Bad user => sudo run me ?
  # shellcheck disable=SC2034  # Unused variable
  E_GIT=85       # Git failed somehow => bug in code, someone added ?
  E_GREP=86      # Error detected grepping it in build.log => Read log
  # shellcheck disable=SC2034  # Unused variable
  E_PYTHON=87    # Python configuration => pyenv -g
  # shellcheck disable=SC2034  # Unused variable
  E_REQ=88       # Some requirements are not found => Read the log/doc

  # By default, run commands
  b_run=1

  # If source, print self doc
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    get_fct_dic
    call_fct_arg --doc
  fi

  # Register caller functions
  declare -ga pre_fct=$(typeset -F -p | cut -d " " -f 3)
  declare -gA fct_dic
  declare -gA cmd_dic
}

shellutil_main "$@"
