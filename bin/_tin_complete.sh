#!/usr/bin/env bash
# Complete command with use of _shellutil function dispatch
#
# Call me like: source _tin_complete.sh
# 1. command name
# 2. arg_lead
# 3. pre_arg_lead
# $COMP_LINE all line

_tin_complete()
{
  #local cur prev words cword
  #_init_completion || return

  readarray -t output < <($1 complete "$1" "$2" "$3")

  fct_list=()
  for line in "${output[@]}"; do
    if [[ "${line:0:1}" == ">" ]]; then
      : #echo -e "${line:1}"
    else
      fct_list+=("$line")
    fi
  done

  COMPREPLY=($(compgen -W '${fct_list[@]}' -- "$2"))

  # Then sort out

  #if [[ $cur == -* ]]; then
  #    local opts=$(_parse_help "$1")
  #    COMPREPLY=($(compgen -W '${opts:-$(_parse_usage "$1")}' -- "$cur"))
  #fi

} &&

complete -F "_tin_complete" tin
complete -F "_tin_complete" chio
