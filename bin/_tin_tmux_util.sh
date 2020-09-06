#!/usr/bin/env bash
# Define tmux utils: A Bash inteligence: Used by <prefix>w => wiki
#
# Used because tmux.conf do not support functions
# TODO: source bash_profile or bashrc

function link {
  # Link to an existing termux window
  # Identified by its name
  # Calle me like _tin_tmux_util,sh link TO_DO 9 "$HOME/wiki/todo" "vi -c'call Windex(2)'" _TIN_TMUX_WINDOW_TO_DO
  window_name="$1" ; window_number="$2" ; start_directory="$3" ; cmd="$4" ; variable_name="$5"

  # If window is in current section, Select it
  if tmux list-windows -F "#{window_name}" | grep "$window_name" &> /dev/null ; then
    tmux select-window -t "$window_name"
  else
    # If window was created once, link to it (mirror)
    if tmux show-environment -g $variable_name &> /dev/null && tmux has-session -t "${!variable_name}" > /dev/null 2>&1 ; then
      tmux link-window -s "${!variable_name}"
      tmux move-window -t $window_number
    # Else, window not existingm create it
    else
      tmux new-window -c "$start_directory" -n "$window_name" "$cmd"
      tmux move-window -t $window_number
      tmux run-shell "tmux set-environment -g $variable_name '#S:#W'"
    fi
  fi
}


if [ $1 == 'link' ]; then
  link "${@:2}"
fi
