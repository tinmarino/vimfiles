#!/usr/bin/env bash
# Function definition to use git with fzf
# From: https://github.com/junegunn/fzf/wiki/Examples


# Variable helper
  _git_log_line_to_hash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
  _view_log_line="$_git_log_line_to_hash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"
  _viewGitLogLineUnfancy="$_git_log_line_to_hash | xargs -I % sh -c 'git show %'"

# Variable fzf
  _fzf_size='--preview-window=right:60% --height 100%'
  _fzf_git_commit_preview=$'f() {
    set -- \$($_git_log_line_to_hash);
    [ \$# -eq 0 ]
    || git show --color=always \$1 $filter; }; f {}'
  _fzf_bind+$'
      --bind "j:down"
  '

# System TODO cd

# Git

fbr() {
  local branches branch
  branches=$(git --no-pager branch -vv && git --no-pager branch -rvv) &&
  branch=$(echo "$branches" |
    fzf +m \
      --ansi --no-sort --reverse --tiebreak=index \
      --preview "$_fzf_git_commit_preview" \
  ) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}


# Log Interface
fli() {
  # From: https://gist.github.com/junegunn/f4fca918e937e6bf5bad#gistcomment-2981199
  #    q = quit
  #    j = down
  #    k = up
  #    alt-k = preview up
  #    alt-j = preview down
  #    ctrl-f = preview page down
  #    ctrl-b = preview page up
  local filter
  if [ -n $@ ] && [ -f $@ ]; then
    filter="-- $@"
  fi

  git log \
    --graph --date-order --date=short --color=always --abbrev=7 --format='%C(auto)%h %an %C(blue)%s %C(yellow)%cr' $@ | \
    fzf \
      --ansi --no-sort --reverse --tiebreak=index \
      --preview "$_fzf_git_commit_preview" \
      $_fzf_size \
      --bind "k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort"
            #  ctrl-m:execute:
            #    (grep -o '[a-f0-9]\{7\}' | head -1 |
            #    xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
            #    {}
            #    FZF-EOF"
}

# PickAce
fpickace(){
  # From https://github.com/junegunn/fzf/issues/1645#issuecomment-586161109
  git log --color=always --pretty=oneline --no-abbrev-commit --decorate \
  | fzf --phony --bind="change:reload:git log -G{q} --color=always --pretty=oneline --no-abbrev-commit --decorate" \
    --preview="git show --color=always {1}" \
    --preview-window right:80% \
    --with-nth=2.. --layout=reverse --no-sort --ansi \
  | awk '{print $1}'
}

# vim: sw=2
