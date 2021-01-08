#!/usr/bin/env bash

# Init, Variables
  # If not running interactively, don't do anything
  [[ -z "$PS1" ]] && return

  # Goto home, not /
  if [[ "$PWD" == / ]] ; then cd "$HOME" || : ; fi

  # Set USER
  [[ -z "$USER" ]] && command -v whoami > /dev/null && USER=$(whoami) && export USER

# Clause: Do I need to load .bash_profile
  # shellcheck disable=SC2154  # os is referenced but not assigned
  if [[ -z "$os" && -z "$v" && -f "$HOME/.bash_profile" ]]; then
    echo Sourcing Profile
  	source "$HOME/.bash_profile"
  fi


# Execute tmux
  if command -v tmux &> /dev/null \
      && [[ -z "$TMUX" \
      &&  ! "$TERM" =~ screen  && ! "$TERM" =~ "screen-256color" \
      &&  ! "$TERM" =~ tmux  &&  ! "$TERM" =~ "tmux-256color" \
      &&  ! "$USER" == "jim" \
      ]] ; then
    if [[ "$HOSTNAME" =~ ^(almatin|tourny)$ ]]; then
      # Set here the first time, then in tmux.conf then in the secondly loaded bashrc
      # For bold and italic
      exec env TERM=tmux-256color tmux
    else
      # for ALMA but some glinch in scroll vim
      exec env TERM=xterm-256color tmux
    fi
  fi


# Callback for Unknown command (tip: install bash-completion on tmux)
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
  command_not_found_handle() {
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


# Head
  # I wanted to be an artists
  # clear
  # Nowrap
  printf '\e[?7l'
  cat << '  EOF'
                             \  |  /
                              \_|_/
                  /|\     ____/   \____
                 / | \        \___/
                /  |  \       / | \
               /___|___\     /  |  \
              _____|_____
              \_________/
   ~~^^~~^~^~~^^~^^^^~~~~^~^~^~^^^^^^^

        |\   \\\\__     o
        | \_/    o_\    o
        >  _  (( <_  oo
        | / \__+___/
        |/     |/

  EOF
  # Reset wrap
  printf '\e[?7h'

# Fast
  # Add "substitute" mnemonic, which the info file left out.
  export PATH="/home/tourneboeuf/Program/GitFuzzy/bin:$PATH"

# PS1
  # PS1, set in bashrc because debian update it in /etc/bashrc
  parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/' ;
  }
  export -f parse_git_branch
  parse_title() {
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

  # Title: Host: CD
  PS1='\[\e]0;\]`parse_title`\007'
  # CD (green)
  PS1+='\[\e[32m\]\w'
  # Git Branch (yellow)
  PS1+='\[\e[33m\]'
  PS1+='`parse_git_branch`'
  PS1+='\[\e[00m\]'
  # New line
  PS1+='\n$ '
  export PS1


# Include, Source, Extension (Alias and Completion)
  ############
  # Completion
  if [[ -f "/etc/bash_completion" ]]; then
    source "/etc/bash_completion"
  #elif [[ -f "$HOME/.local/usr/share/bash-completion/bash_completion" ]]; then
  #  source "$HOME/.local/usr/share/bash-completion/bash_completion"
  fi

  # Alias
  if [[ -f "$HOME/.bash_aliases.sh" ]]; then
    source "$HOME/.bash_aliases.sh"
  fi

  # ShellArsenal Complete
  if [[ -f "$v/bin/_tin_complete.sh" ]]; then
    source "$v/bin/_tin_complete.sh"
  fi

  # Tmux completion
  if command -v _get_comp_words_by_ref &> /dev/null && [[ -f "$v/bin/_tinrc-tmux-completion.sh" ]]; then
    source "$v/bin/_tinrc-tmux-completion.sh"
  fi

  # Fzf bindings
  if [[ -f "$HOME/.fzf.bash" ]]; then
    # Warning on termux, comment /home/tourneboeuf/Program/Fzf/shell/completion.bash
    source "$HOME/.fzf.bash"
  fi

  # Alacrity Completion
  if [[ -f "$v/scripts/completion/alacritty" ]]; then
    source "$v/scripts/completion/alacritty"
  fi

  # Fzf
  [[ -f "$v/bin/_tinrc-fzf-function.sh" ]] && source "$v/bin/_tinrc-fzf-function.sh"
  #[[ -f "$h/Program/ForGit/forgit.plugin.sh" ]] && source "$h/Program/ForGit/forgit.plugin.sh"

  # Pip bash completion start
  _pip_completion()
  {
      mapfile -t COMPREPLY < <( \
        COMP_WORDS="${COMP_WORDS[*]}" \
        COMP_CWORD=$COMP_CWORD \
        PIP_AUTO_COMPLETE=1 $1 2>/dev/null )
  }
  complete -o default -F _pip_completion pip
  # pip bash completion end

# Alma
  be(){ sudo -u "$1" -i; }
  complete -W "mgr op proc root" be
  alias mgr='be almamgr'
  alias op='be almaop'
  alias proc='be almaproc'
  alias root='be root'
  # With a tmux singleton, like it or not
  alias acse2='ssh -X mtourneb@acse2-gns.sco.alma.cl -t "source ./.bash_profile; ./.local/bin/tmux new-session -A -s tin"'


# Bind
  # Enable Readline not waiting for additional input when a key is pressed.
  set keyseq-timeout 10
  bind -x '"\ee":fzf_open'
  bind -x '"\er":fzf_dir ~/wiki/rosetta/Lang'
  bind -x '"\eh":fzf_dir .'
  bind -x '"\el":fzf_line .'
