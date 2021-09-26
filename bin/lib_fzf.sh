#!/usr/bin/env bash


# Variable helper
  _git_log_line_to_hash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
  _view_log_line_unfancy="$_git_log_line_to_hash | xargs -I % sh -c 'git show %'"

# Variable fzf
  _fzf_base=(--ansi --no-sort --reverse "--tiebreak=index")
  _fzf_size=("--preview-window=right:50%" --height 100%)
  _fzf_bind=(
    --bind "ctrl-m:execute:
              (grep -o '[a-f0-9]\{7\}' | head -1 |
              xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
              {}
              FZF-EOF"
    --bind "alt-v:execute:$_view_log_line_unfancy | $PAGER -"
  )
