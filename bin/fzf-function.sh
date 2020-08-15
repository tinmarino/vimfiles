#!/usr/bin/env bash
# Function definition to use git with fzf



# Log Interface
fgli() {
  # From: https://gist.github.com/junegunn/f4fca918e937e6bf5bad
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
    --graph --color=always --abbrev=7 --format='%C(auto)%h %an %C(blue)%s %C(yellow)%cr' $@ | \
    fzf \
      --ansi --no-sort --reverse --tiebreak=index \
      --preview "f() { set -- \$(echo -- \$@ | grep -o '[a-f0-9]\{7\}'); [ \$# -eq 0 ] || git show --color=always \$1 $filter; }; f {}" \
      --bind "j:down,k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort,ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
                FZF-EOF" \
      --preview-window=right:60% \
      --height 80%
  #git-commit-show () 
  #{
  #  git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"  | \
  #   fzf --ansi --no-sort --reverse --tiebreak=index --preview \
  #   'f() { set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}"); [ $# -eq 0 ] || git show --color=always $1 ; }; f {}' \
  #   --bind "j:down,k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort,ctrl-m:execute:
  #                (grep -o '[a-f0-9]\{7\}' | head -1 |
  #                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
  #                {}
  #FZF-EOF" --preview-window=right:60%
  #}
}

# PickAce
fgpickace(){
  # From https://github.com/junegunn/fzf/issues/1645#issuecomment-586161109
  git log --color=always --pretty=oneline --no-abbrev-commit --decorate \
  | fzf --phony --bind="change:reload:git log -G{q} --color=always --pretty=oneline --no-abbrev-commit --decorate" \
    --preview="git show --color=always {1}" \
    --preview-window right:80% \
    --with-nth=2.. --layout=reverse --no-sort --ansi \
  | awk '{print $1}'
}

# vim: sw=2
