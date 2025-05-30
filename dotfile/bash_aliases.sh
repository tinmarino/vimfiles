#!/usr/bin/env bash
# vim: sw=2:ts=2:fdm=marker
#
# Alias definition
#
# shellcheck disable=SC2154  # v is referenced but not assigned
# shellcheck disable=SC2015  # Note that A && B || C is not if-then-else. C may run when A is true


# Declare Helper Functions {{{1
mcomplete_cmd(){
  # Get cmd: first word
  # shellcheck disable=SC2206  # quote
  a_cmd=( $1 )
  cmd=${a_cmd[0]}

  # Get complete function
  # shellcheck disable=SC2207  # Prefer mapfile or read -a to split command output
  line=( $(complete -p "$cmd" 2> /dev/null ) ) || return 1
  fct=${line[-2]}

  # Return function
  echo "$fct"
}
export -f mcomplete_cmd

malias(){
  # shellcheck disable=SC2139  # This expands when defined => OK
  alias "$1"="$2"
  [[ windows != "$os" ]] && command -v _completion_loader > /dev/null && _completion_loader "$2"
  fct="$(mcomplete_cmd "$2")"
  [[ -n "$fct" ]] && complete -F "$fct" "$1" > /dev/null 2>&1
}
export -f malias

__complete_g(){
  [[ ! "$os" == "windows" ]] && command -v _completion_loader > /dev/null && _completion_loader git
  __git_wrap__git_main "$@"
}
export -f __complete_g

__complete_m(){
  [[ ! "$os" == "windows" ]] && command -v _completion_loader > /dev/null && _completion_loader man
  __git_wrap__git_main "$@"
}
export -f __complete_m


# Shortcut {{{1
# With completion {{{2
alias g=git  # Time 15ms to load completion script
complete -o bashdefault -o default -o nospace -F __complete_g g
alias m=man  # Time: 3ms
complete -F _man m

# Small as Huffman {{{2
alias f=find
alias h="history | rg "
alias o=xdg-open
alias t=translate
alias v=vim
alias s=sgpt
alias x="xsel --input --clipboard"
alias fr="find . | rg "

# Little longer {{{2
alias disas='objdump -drwC -Mintel'
alias ll='ls -lh'
alias gs='git status'  # Prevent confusion with ghostscript
alias gc='git commit -m'  # Prevent confusion with count graph components
alias so=source
alias ssh='TMUX= TERM=xterm-256color ssh'
alias rp=realpath

# Tin
alias ta='tin aws'

# Languages
alias fd=fdfind
alias py=python3
alias py2=python2
alias py3=python3
alias pl=perl
alias ra='raku -I.'
alias terminal='TMUX= alacritty'
alias te='TMUX= alacritty'
alias terminal_raw='alacritty'
alias traw='alacritty -e env -i INPUTRC= bash --noprofile --norc'
alias tnotmux='alacritty'
alias vi=vim
alias vimm=vim
#alias ipy='jupyter-console'
#alias ira='jupyter-console --kernel=raku'
#alias ija='jupyter-console --kernel=java'
alias rgi='rg -i'
alias fri='fr -i'

# ShellGPT
#alias translate='sgpt --model gpt-3.5-turbo-1106 --role Translate <<EOF'

# New terminal (without tmux)
alias tnew='TMUX=1 gnome-terminal'

# TODO traw without any rc for testing


# Fzf {{{1
# -- And all the rest in 7ms
alias fgl=fzf_git_log
alias fo=fzf_open
alias ff=fzf_line
alias fl=fzf_line
alias fcd=fzf_cd


# Path variable {{{1
# shopt -s direxpand
export b="$v/bin"
export p="$v/pack/bundle/opt/"
export pw="$v/pack/bundle/opt/wiki"
export t="$HOME/wiki/todo"
export w="$HOME/wiki/wiki"

# MARK: Deprecation: never used
export vb="$v/bin"
export vd="$v/dotfile"
export wt="$HOME/wiki/todo"
export wa="$HOME/wiki/alma"


# Tmux {{{1
# TODO never used, deprectation MARK
alias tl="tmux list-sessions"
alias tks='tmux kill-session -t'


# Shortcut largers
  export TRASH="$HOME/.Trash"

  # Bigger for memory
  alias open='xdg-open'
  alias clip="xclip -selection c"
  #alias find="find -not -path '*/\.*'"

  # Utils
  # shellcheck disable=SC2139  # This expands when defined
  alias clean_tex="mv -t $TRASH *.aux *.log *.fls *.fdb_latexmk *.out *synctex.gz *.tex.backup *.4ct *.4tc *.idv *.lg *.tmp *.xref *.xdv *.dvi *.bak *.toc *.nav *.snm"
  alias clip='xclip -selection c'

  # Safe RM
  # shellcheck disable=SC2139  # This expands when defined, not when used
  #alias rm="echo better use trash; mv -f -t $TRASH"
  alias trash="mv -f -t $TRASH"
  #alias rmv='command rm'
  alias trash2="trash-put"

  # CD ..
  alias p='cd ..'
  alias pp='cd ../..'
  alias ppp='cd ../../..'
  alias pppp='cd ../../../..'
  alias ppppp='cd ../../../../..'
  alias pppppp='cd ../../../../../..'
  alias ppppppp='cd ../../../../../../..'
  alias pppppppp='cd ../../../../../../../..'


# Color improve (ls, grep)
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'


# Fast
