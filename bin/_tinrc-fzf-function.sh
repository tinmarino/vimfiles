#!/usr/bin/env bash
# Define Functions to use git with fzf
# From: https://github.com/junegunn/fzf/wiki/Examples
# shellcheck disable=SC2015  # Note that A && B || C is not if-then-else. C may run when A is true


# Variable helper
  _git_log_line_to_hash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
  _view_log_line_unfancy="$_git_log_line_to_hash | xargs -I % sh -c 'git show %'"

# Variable fzf
  # Unused
  # _view_log_line="$_git_log_line_to_hash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"
  # _fzf_preview=(--preview "$v/bin/_tinrc-fzf-preview.sh {}")
  # # TODO see filter for file
  # _fzf_gcpreview=$'func() {
  #   set -- \$('$_git_log_line_to_hash');
  #   [ \$# -eq 0 ] || git show --color=always %; }; func {}'
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

######################################################################
# System TODO cd
######################################################################


# Vi <= Binded alt-e <= BashRc
fzf_open() {
  # shellcheck disable=SC2154  # v is referenced but not assigned
  IFS=$'\n' out="$(fzf --query="$1" --exit-0 --expect=ctrl-o,ctrl-e \
    --preview "$v/bin/_tinrc-fzf-preview.sh {}")"
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [[ "$key" = ctrl-o ]] && xdg-open "$file" || ${EDITOR:-vim} "$file"
  fi
}

fzf_dir(){
  pushd "$1" > /dev/null || echo "Error: Cannot cd to $1"
  out="$(rg --color always --follow --files | fzf \
    --ansi \
    --preview "$v/bin/_tinrc-fzf-preview.sh $1/{}")"
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [[ "$key" = ctrl-o ]] && xdg-open "$file" || ${EDITOR:-vim} "$file"
  fi
  popd > /dev/null || return 1
}



fzf_line() {
  # Interactive search.
  # Usage: `ff` or `ff <folder>`.
  [[ -n "$1" ]] && cd "$1" || exit 2  # go to provided folder or noop
  RG_DEFAULT_COMMAND="rg -i -l --hidden --no-ignore-vcs"
  
  selected=$(
  FZF_DEFAULT_COMMAND="rg --files" fzf \
    -m \
    -e \
    --ansi \
    --phony \
    --reverse \
    --bind "ctrl-a:select-all" \
    --bind "f12:execute-silent:(vim -b {})" \
    --bind "change:reload:$RG_DEFAULT_COMMAND {q} || true" \
    --preview "rg -i --pretty --context 2 {q} {}" | cut -d":" -f1,2
  )
  
  # Open multiple files in editor
  [[ -n "$selected" ]] && vim "$selected"
}

# cf - fuzzy cd from anywhere
# ex: cf word1 word2 ... (even part of a file name)
# zsh autoload function
fzf_cd() {
  local file

  file="$(locate -Ai -0 "$@" | grep -z -vE '~$' | fzf --read0 -0 -1)"

  if [[ -n $file ]]
  then
     if [[ -d $file ]]
     then
        cd -- "$file" || return
     else
        cd -- "${file:h}" || return
     fi
  fi
}


######################################################################
# Git
######################################################################

# Log Interface
fzf_git_log() {
  # From: https://gist.github.com/junegunn/f4fca918e937e6bf5bad#gistcomment-2981199
  # Log ideas: --date-order --date=short  => Ugly for AlmaSW
  local filter
  if [ -n "$*" ] && [ -f "$*" ]; then
    filter="-- $*"
  fi

  git log \
    --graph --color=always --abbrev=7 --format='%C(auto)%h %an %C(blue)%s %C(yellow)%cr' "$@" | \
    fzf \
      "${_fzf_base[@]}" \
      --preview "f() { set -- \$(echo -- \$@ | grep -o '[a-f0-9]\{7\}'); [ \$# -eq 0 ] || git show --color=always \$1 $filter; }; f {}" \
      "${_fzf_size[@]}" \
      "${_fzf_bind[@]}"
}
alias fgl=fzf_git_log


fbr() {
  local branches branch
  branches=$(git --no-pager branch -vv && git --no-pager branch -rvv) &&
  branch=$(echo "$branches" |
    fzf +m \
      "${_fzf_base[@]}" \
      --preview "f() { set -- \$(echo -- \$@ | grep -o '[a-f0-9]\{7\}'); [ \$# -eq 0 ] || git show --color=always \$1 $filter; }; f {}" \
      "${_fzf_size[@]}" \
      "${_fzf_bind[@]}"
  ) &&
  git checkout "$(echo "$branch" | awk '{print $1}' | sed "s/.* //")"
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

# Kill
fkill() {
  local pid 
  if [ "$UID" != "0" ]; then
    pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
  else
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  fi  

  if [ "x$pid" != "x" ]
  then
    echo "$pid" | xargs kill -"${1:-9}"
  fi  
}

# vim: sw=2:ts=2
