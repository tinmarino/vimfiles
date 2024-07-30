#!/usr/bin/env bash

# Complete shellGPT
__complete_sgpt(){
  # Remove the line trail for the completion (ignore it)
  COMP_LINE=${COMP_LINE:0:$COMP_POINT}

  # Add last argument if cursor is one space after last word
  # -- So that we know an other argument is expected
  [[ ${COMP_LINE:COMP_POINT-1:1} == " " ]] && COMP_LINE+='""'
  # Parse command line
  eval "set -- $COMP_LINE"
  COMPREPLY=()
  local pad_raw='-----------------'


  if ((${#@} > 0)); then
    local arg_prefix=${*: -1}
  else
    local arg_prefix=""
  fi
  if ((${#@} > 1)); then
    local arg_before=${*: -2:1}
  else
    local arg_before=""
  fi

  local doc='
    ----------- Options : -----------------------------------
    --model       : TEXT Large language model to use [default: gpt-4-1106-preview]
    --temperature : FLOAT RANGE [0.0<=x<=2.0]  Randomness of generated output. [default: 0.0]
    --top-p       : FLOAT RANGE [0.0<=x<=1.0]  Limits highest probable tokens (words). [default: 1.0] │
    --md          : Prettify markdown output. [default: md]
    --no-md       : No md
    --editor      : Open $EDITOR to provide a prompt. [default: no-editor] │
    --no-editor   : No editor
    --cache       : Cache completion results. [default: cache]
    --no-cache    : No cache
    --version     : Show version
    --help        : Show this message and exit
    -------- Assistance : -----------------------------------
    --shell       : Interface to generate and execute shell commands [-s]
    --interaction     : Interactive mode for --shell option. [default: interaction]
    --no-interaction  : No Interaction
    --describe-shell  : Describe a shell command [-d]
    --code            : Generate only code [-c]
    --functions       : Allow function calls. [default: functions]
    --no-functions    : No functions
    -------------- Chat : -----------------------------------
    --chat        : TEXT  Follow conversation with id, use "temp" for quick session. [default: None]
    --repl        : TEXT  Start a REPL (Read–eval–print loop) session. [default: None]
    --show-chat   : TEXT  Show all messages from provided chat id. [default: None]
    --list-chats  : List all existing chat ids [-lc]
    -------------- Role : -----------------------------------
    --role        : TEXT  System role for GPT model. [default: None]
    --create-role  : TEXT  Create role. [default: None]
    --show-role    : TEXT  Show role. [default: None]
    --list-roles   : List roles [-lr]
  '

  case $arg_before in
    --show-chat|--chat)
      while IFS= read -r line; do
        filter_prefix "$arg_prefix" "$line"
      done < <(sgpt --list-chats | sed 's|^.*/||')
      ;;
    --show-role|--role)
      while IFS= read -r line; do
        local possible_arg="${line%% : *}"
        filter_prefix "$arg_prefix" "$possible_arg"
      done < <(
        while IFS= read -r role_path; do
          role_name=${role_path##*/}
          role_name=${role_name%%.json}
          role_desc=$(jq '.role' < "$role_path")
          echo "$role_name : $role_desc"
        done < <(sgpt --list-roles)
      )
      ;;
    *)
      while IFS= read -r line; do
        local possible_arg="${line%% : *}"
        filter_prefix "$arg_prefix" "$possible_arg"
      done <<< "$doc"
  esac


  # If Only one completion: clean it
  if (( 1 == ${#COMPREPLY[*]} )); then
    # Remove ' ---- ' and everything after
    COMPREPLY[0]="${COMPREPLY[0]%%  -*}"
  elif (( 0 < ${#COMPREPLY[*]} )); then
    local line_dash=$(printf '%.0s-' $(seq 1 $(( COLUMNS/2 + 2 ))))
    local line_title="ShellGPT: a terminal REPL client for AI large language models (LLM) chats"
    local line_url="Source: https://github.com/TheR1D/shell_gpt"
    COMPREPLY=("$line_title" "$line_url" "$line_dash" "${COMPREPLY[@]}" "$line_dash")
  fi

  # Print solutions and comments
  #printf "%s\n" "${COMPREPLY[@]}"
}

filter_prefix(){
  : 'Filter word <arg2> keeping only thos with the prefix <arg1>
    Return in COMPREPLY
  '
  local prefix=${1:-}
  local word=${2:-}

  # Chomp: Trail leading and trailing spaces
  # From: https://unix.stackexchange.com/a/360648/257838
  shopt -s extglob
  word=${word##+([[:space:]])}
  word=${word%%+([[:space:]])}

  #echo
  #print_args "$@"
  #echo numbe ${#@}
  #echo possi $word
  #echo prefi $prefix
  #echo befor $arg_before
  # Clause do not work if empty
  [[ -z "$word" ]] && return

  # If match current argument prefix: add it to COMPREPLY
  if [[ "$word" == "$prefix"* ]]; then
    local comment="${line#* : }"
    local pad=${pad_raw:${#word}}
    # Safe: make pad be at least one '-' in order to split it well and get only the fct name
    # -- when autocompletion put the result in the command line
    [[ -z "$pad" ]] && pad='-'
    printf -v line "%s  %s  %s" "$word" "$pad" "$comment"
    COMPREPLY+=("$line")
  fi
}

complete -o nosort -F __complete_sgpt sgpt
complete -o nosort -F __complete_sgpt s
