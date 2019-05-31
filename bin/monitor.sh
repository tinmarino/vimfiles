#!/bin/bash

# monitor les fenetre
tmux_monitor_array=(top 'iftop -i wlp3s0' 'sudo iotop' 'watch wmctrl -l')

function tmux_start_monitor_session {
	tmux new-session -s monitor -n 0 bash\;\
	split-window -h bash\;\
	split-window -v bash\;\
	select-pane -t 0 \;\
	split-window -v bash \;\
	set -g pane-border-status top \;\
	set -g pane-border-format "#P: #{pane_current_command}" \;\
	send-keys -t 0 "${tmux_monitor_array[0]}" Enter \;\
	send-keys -t 1 "${tmux_monitor_array[1]}" Enter \;\
	send-keys -t 2 "${tmux_monitor_array[2]}" Enter \;\
	send-keys -t 3 "${tmux_monitor_array[3]}" Enter

}

tmux attach -t monitor || tmux_start_monitor_session
