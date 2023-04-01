#!/usr/bin/env bash


# Variable helper
_GIT_LOG_LINE_TO_HASH="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_VIEW_LOG_LINE_UNFANCY="$_GIT_LOG_LINE_TO_HASH | xargs -I % sh -c 'git show %'"


# Variable fzf
_FZF_BASE=(--ansi --no-sort --reverse "--tiebreak=index")
_FZF_SIZE=("--preview-window=right:50%" --height 100%)
_FZF_BIND=(
  --bind "ctrl-m:execute:
            (grep -o '[a-f0-9]\{7\}' | head -1 |
            xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
            {}
            FZF-EOF"
  --bind "alt-v:execute:$_view_log_line_unfancy | $PAGER -"
)
