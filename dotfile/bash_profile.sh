#!/usr/bin/env bash

# Guard: if not Bash exit
if [ -z "$BASH_VERSION" ]; then
  exit
fi

# History
export HISTSIZE=1000000
export HISTFILESIZE=2000000
export HISTTIMEFORMAT='%Y-%m-%dT%H:%M:%S'
  
shopt -s histappend
. "$HOME/.cargo/env"
