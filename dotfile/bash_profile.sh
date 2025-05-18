#!/usr/bin/env bash
# vim: sw=2:ts=2:fdm=marker
# Bash Profile for login shell
# Author: Tinmarino

# Guard: if not Bash exit
if [ -z "$BASH_VERSION" ]; then
  exit
fi

# History {{{2
export HISTSIZE=1000000
export HISTFILESIZE=2000000
export HISTTIMEFORMAT='%Y-%m-%dT%H:%M:%S'
  
shopt -s histappend

# Colorize LS {{{2
if command -v dircolors > /dev/null; then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi
