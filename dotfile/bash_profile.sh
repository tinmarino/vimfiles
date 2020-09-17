#!/usr/bin/env bash

# Guard: if not Bash exit
if [ -z "$BASH_VERSION" ]; then
  exit
fi
# DEBUG
export BASHPROFILE_SOURCED=1

# Init, Variables
  # Set OS
  export h="$HOME"
  # shellcheck disable=SC2088
  uname=$(uname -a)
  uname=${uname,,}
  case $uname in
  *"android"*)
    export os="termux"
    export v="$HOME/.vim"
    ;;
  *"linux"*)
    export os="unix"
    export v="$HOME/.vim"
    ;;
  *"mingw"*)
    export os="windows"
    export v="$HOME/vimfiles"
    ;;
  esac

  # Man
  export PAGER="vman"
  export TEXMFHOME="$HOME/Program/Tlmgr"


# Path
  # Save
  export path_save=$PATH
  export PATH=""
  # set PATH so it includes user's private bin if it exists
  if [ -d "$HOME/bin" ] ; then
      PATH="$HOME/bin:$PATH"
  fi
  
  # set PATH so it includes user's private bin if it exists
  if [ -d "$HOME/.local/bin" ] ; then
      PATH="$HOME/.local/bin:$PATH"
  fi

  export PATH="$HOME/.cargo/bin:$PATH"
  # Windows fast
  export PATH="$PATH:/c/Program Files/Vim/vim82"
  # My script
  export PATH=$PATH:$HOME/.vim/bin
  export PATH=$PATH:$HOME/Bin
  # Node after npm config set prefix ~/.npm
  export PATH=$PATH:$HOME/.npm/bin
  # Perl6
  export RAKUDOLIB=$HOME/.raku
  export PATH=$PATH:$HOME/Program/Raku/Doc/bin
  export PATH=$PATH:$HOME/Program/Raku/Repo/install/bin
  export PATH=$PATH:$HOME/Program/Raku/Repo/install/share/perl6/site/bin
  export PATH=$PATH:$HOME/Program/Raku/Z/bin
  export PATH=$PATH:$HOME/.raku/share/perl6/site/bin
  export PATH=$PATH:$HOME/.raku/bin
  # Python
  #export PATH=$PATH:$HOME/Program/Conda/bin
  export PATH=$PATH:$HOME/.local/usr/local/bin
  # Rust
  export PATH=$PATH:$HOME/.cargo/bin
  # Android sdk
  export PATH=$PATH:$HOME/Program/Android/Sdk/Tools/sdk-tools-linux-4333796/tools
  export PATH=$PATH:$HOME/Program/Android/Sdk/Tools/sdk-tools-linux-4333796/tools/bin
  export PATH=$PATH:$HOME/Program/Eclipse/eclipse
  export ANDROID_HOME=$HOME/Program/Android/Sdk/Tools/sdk-tools-linux-4333796
  export ANDROID_SDK=$HOME/Program/Android/Sdk/Tools/sdk-tools-linux-4333796
  # Programs
  export PATH=$PATH:/usr/local/cuda-10.0/bin
  export PATH=$PATH:$HOME/Program/Metapixel/metapixel
  # Readd
  export PATH=$PATH:$path_save

  # Lib
  export LD_LIBRARY_PATH=$HOME/Bin:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$HOME/Program/Gecode:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=/usr/lib/python3.7/config-3.7m-x86_64-linux-gnu:$LD_LIBRARY_PATH
  export NDK=$HOME/Program/Ndk/Current

  # shellcheck source=/home/tourneboeuf/.fzf.bash
  [[ -f "$HOME/.fzf.bash" ]] && source "$HOME/.fzf.bash"


# Unknown command callback (tip: install bash-completion on tmux)
  print_stack() {
     STACK=""
     local i message="${1:-""}"
     local stack_size=${#FUNCNAME[@]}
     # to avoid noise we start with 1 to skip the get_stack function
     for (( i=1; i<stack_size; i++ )); do
        local func="${FUNCNAME[$i]}"
        [ "x$func" = x ] && func=MAIN
        local linen="${BASH_LINENO[$(( i - 1 ))]}"
        local src="${BASH_SOURCE[$i]}"
        [ x"$src" = x ] && src=non_file_source

        STACK+=$'\n'"   at: $func $src $linen"
     done
     STACK="${message}${STACK}"
     echo "$STACK"
  }
  export -f print_stack
  function command_not_found_handle {
    # If starting with g : git
    if [[ "${1:0:1}" == "g" ]]; then
      # shellcheck disable=SC2086
      git "${1:1}" $2
    # If any shit, echo bash default errmsg
    else
      echo "bash(rc): $1: command not found"
      print_stack ""
    fi
  }
  export -f command_not_found_handle


# Preferences
  # Enable directory with $
  shopt -s direxpand
  # Avoid c-s freezing
  stty -ixon

  # Vi as default `git commit`
  export EDITOR='vim'
  # Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
  shopt -s checkwinsize

  # French characters
  stty cs8 -istrip -parenb
  bind 'set convert-meta off'
  bind 'set meta-flag on'
  bind 'set output-meta on'

  # History
  # append instead of overwrite
  shopt -s histappend
  export HISTSIZE=100000
  export HISTFILESIZE=100000
  export HISTCONTROL=ignoredups


# Prompt
  # Save history after each executed line
  export PROMPT_COMMAND+='history -a;'

  # PS1, set in bashrc because debian update it in /etc/bashrc
  function parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/' ;
  }
  export -f parse_git_branch
  function parse_title() {
    host=$(hostname)
    # hsot
    if [[ "$host" == "tourny" ]]; then
      res=''
    else
      res="<$host>:   "
    fi
    res+=$(dirs +0)
    echo "$res"
  }
  export -f parse_title


# Fzf functions
  #_vim_escaped2='let out = map(fzf#vim#_recent_files(), \"substitute(v:val, \\\"\\\\\\\\~\\\", \\\"'$HOME'\\\", \\\"\\\")\")'
  _vim_escaped2='let out = fzf#vim#_recent_files()'
  _fzf_cmds="bash -c \"
    vim -NEs
      +'redir>>/dev/stdout | packadd fzf.vim'
      +'$_vim_escaped2'
      +'echo join(out, \\\"\\\\n\\\")'
      +'redir END | q';
    rg --color always --files \\\".\\\";
    cd \\\"$HOME\\\" && rg --color always --files | awk '{print \\\"~/\\\" \\\$0}';
    cd \\\"$v\\\" && rg --color always --files | awk '{print \\\"$v/\\\" \\\$0}';
  \""
  export FZF_DEFAULT_COMMAND="${_fzf_cmds//$'\n'/}"
  # shellcheck disable=SC2206,SC2191
  fzf_opts=(
    # Enable exact match
    #--exact
    --ansi
    # Multi Selection
    --multi
    --reverse
    # First olfiles
    #--no-sort
    --preview-window=right:50% --height 100%
    #--preview \"$v/bin/_tinrc-fzf-preview.sh {}\"
    --bind ?:toggle-preview
    --bind ctrl-space:toggle-preview
    --bind ctrl-j:down
    --bind ctrl-k:up
    --bind ctrl-u:half-page-up
    --bind ctrl-d:half-page-down
    --bind ctrl-s:toggle-sort
    --bind alt-u:preview-page-up
    --bind alt-d:preview-page-down
    #--bind ctrl-y:preview-up
    #--bind ctrl-e:preview-down
  )
  export FZF_DEFAULT_OPTS="${fzf_opts[*]}"
  # ForGit plugin
  export FORGIT_LOG_FZF_OPTS="$FZF_DEFAULT_OPTS"
  export FORGIT_DIFF_FZF_OPTS="$FZF_DEFAULT_OPTS"
  export FORGIT_DIFF_FZF_OPTS="$FZF_DEFAULT_OPTS"
  # From: https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings
  export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
  export FZF_CTRL_R_OPTS="--sort --exact --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
  # shellcheck source=/home/tourneboeuf/.vim/bin/_tinrc-fzf-function.sh
  [[ -f "$v/bin/_tinrc-fzf-function.sh" ]] && source "$v/bin/_tinrc-fzf-function.sh"
  # shellcheck source=/home/tourneboeuf/Program/ForGit/forgit.plugin.sh
  [[ -f "$h/Program/ForGit/forgit.plugin.sh" ]] && source "$h/Program/ForGit/forgit.plugin.sh"


# Source bashrc ?
  #if [ -n "$BASH_VERSION" ]; then
  #    # include .bashrc if it exists
  #    if [ -f "$HOME/.bashrc" ]; then
  #    # shellcheck source=/home/tourneboeuf/.bashrc
  #	  source "$HOME/.bashrc"
  #    fi
  #fi



# vim:sw=2:ts=2:foldignore=:
