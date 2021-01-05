#!/usr/bin/env bash
# Copy via Operating System Command 52 ANSI escape sequence to controlling terminal

# -- Used by Tmux
# -- Ex: echo -e "\033]52;c;$(base64 <<< hellov0.1)\a"
#
# More for vim: https://stackoverflow.com/questions/45247929/system-clipboard-vim-within-tmux-within-ssh-session
# 

# Get In <- data either form stdin or from file
buf=$(cat "$@")
echo Received "$buf" >> /tmp/copy

# Get len <- In buf
buflen=$( printf %s "$buf" | wc -c )

# Ref: https://sunaku.github.io/tmux-yank-osc52.html
# The maximum length of an OSC 52 escape sequence is 100_000 bytes, of which
# 7 bytes are occupied by a "\033]52;c;" header, 1 byte by a "\a" footer, and
# 99_992 bytes by the base64-encoded result of 74_994 bytes of copyable text
maxlen=74994 

# Warn if exceeds maxlen
if [ "$buflen" -gt "$maxlen" ]; then
  printf "input is %d bytes too long" "$(( buflen - maxlen ))" >&2
fi

# Build up OSC 52 ANSI escape sequence
esc="\e]52;c;$( printf %s "$buf" | head -c $maxlen | base64 | tr -d '\r\n' )\a"
esc="\ePtmux;\e$esc\e\\"

# resolve target terminal to send escape sequence
# if we are on remote machine, send directly to SSH_TTY to transport escape sequence
# to terminal on local machine, so data lands in clipboard on our local machine
#pane_active_tty=$(tmux list-panes -F "#{pane_active} #{pane_tty}" | awk '$1=="1" { print $2 }')
#target_tty="${SSH_TTY:-$pane_active_tty}"

printf "%s" "$esc"
#printf "%s" "$esc" > /dev/tty
