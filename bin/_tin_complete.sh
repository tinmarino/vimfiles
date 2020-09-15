#!/usr/bin/env bash
# Complete command with use of _shellutil function dispatch
#
# Call me like: source _tin_complete.sh
# 1. command name
# 2. arg_lead
# 3. pre_arg_lead
# 4. array of word
# $COMP_LINE all line
# $COMP_CWORD Index of cursor in word unit
# -- $COMP_WORDS[@] all words not passed in env <- array
# See: padding: https://stackoverflow.com/questions/4409399

_tin_complete()
{
  #local cur prev words cword
  #_init_completion || return
  local pad_raw='-----------------'

  export TIN_TEST=3
  export TIN_TEST3=(alpha bravo charlie)
  export TIN_TEST4="alpha bravo charlie"
  declare -a TIN_TEST2=("${COMP_WORDS[@]}")
  export TIN_TEST2
  export COMP_CWORD
  # echo -e "\nTin in first: ${COMP_WORDS[*]}, $COMP_CWORD" >> log

  # Launch command
  readarray -t output < <($1 complete "$1" "$2" "$3" "${COMP_WORDS[@]}")

  COMPREPLY=()
  for line in "${output[@]}"; do
    cmd_name="${line%% - *}"
    # Filter line starting with > (Obsolete)_
    if [[ "${line:0:1}" == ">" ]]; then
      : #echo -e "${line:1}"
    # If match $2, add it
    elif [[ "$cmd_name" == "$2"* ]]; then
      comment="${line#* - }"
      printf -v line "%s  %s  %s" "$cmd_name" "${pad_raw:${#cmd_name}}" "$comment"
      COMPREPLY+=("$line")
    fi
  done

  
  #COMPREPLY=($(compgen -W "${output[@]}" -- "$2"))
  #COMPREPLY=($(compgen -W '${fct_list[@]}' -- "$2"))
  #echo "REPLY: ${COMPREPLY[@]}"

  # If Only one completion
  if [[ ${#COMPREPLY[*]} -eq 1 ]]; then
    # See: https://stackoverflow.com/questions/7267185
    # Remove ' - ' and everything after
    COMPREPLY=( ${COMPREPLY[0]%%  -*} )
    # Remove ' - ' and everything after
    COMPREPLY=( ${COMPREPLY[0]#-- } )
  fi


  ## Then sort out
  #if [[ $cur == -* ]]; then
  #    local opts=$(_parse_help "$1")
  #    COMPREPLY=($(compgen -W '${opts:-$(_parse_usage "$1")}' -- "$cur"))
  #fi

} && {
  complete -F "_tin_complete" tin_doc
  complete -F "_tin_complete" tin
  complete -F "_tin_complete" chio
}
