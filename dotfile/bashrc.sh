#!/usr/bin/env bash

# Clause In
  # If not running interactively, don't do anything
  [[ -z "$PS1" ]] && return

  # Goto home, not /
  if [[ "$PWD" == / ]] ; then cd "$HOME" || : ; fi

  # Set USER
  [[ -z "$USER" ]] && command -v whoami > /dev/null && USER=$(whoami) && export USER


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


# Print Head
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


# Variables personal
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
  if [[ ! "$USER" == "jim" ]]; then
    export PAGER="vman"
  fi
  export TEXMFHOME="$HOME/Program/Tlmgr"


# Variables Bash
  # Enable directory with $
  # shopt -s direxpand
  # Avoid c-s freezing
  stty -ixon

  # Vi as default `git commit`
  export EDITOR='vim'
  # Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
  shopt -s checkwinsize

  # History
  # Append instead of overwrite
  shopt -s histappend
  export HISTSIZE=100000
  export HISTFILESIZE=10000000
  export HISTCONTROL=ignoredups
  # Save history after each executed line
  export PROMPT_COMMAND+='history -a;'

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
    --preview \"$v/bin/_tinrc-fzf-preview.sh {}\"
    --bind ?:toggle-preview
    --bind ctrl-space:toggle-preview
    --bind ctrl-j:down
    --bind ctrl-k:up
    --bind ctrl-u:half-page-up
    --bind ctrl-d:half-page-down
    --bind ctrl-s:toggle-sort
    --bind alt-u:preview-half-page-up
    --bind alt-d:preview-half-page-down
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
  #   maybe source "$HOME/.local/usr/share/bash-completion/bash_completion"
  [[ -f "/etc/bash_completion" ]] && source "/etc/bash_completion"

  # Alias
  [[ -f "$HOME/.bash_aliases.sh" ]] && source "$HOME/.bash_aliases.sh"

  # ShellArsenal Completion
  [[ -f "$v/bin/_tin_complete.sh" ]] && source "$v/bin/_tin_complete.sh"

  # Tmux completion
  command -v _get_comp_words_by_ref &> /dev/null && [[ -f "$v/bin/_tinrc-tmux-completion.sh" ]] && source "$v/bin/_tinrc-tmux-completion.sh"

  # Fzf bindings
  # Warning on termux, comment /home/tourneboeuf/Program/Fzf/shell/completion.bash
  [[ -f "$HOME/.fzf.bash" ]] && source "$HOME/.fzf.bash"

  # Rust
  source "$HOME/.cargo/env"

  # Alacrity Completion
  [[ -f "$v/scripts/completion/alacritty" ]] && source "$v/scripts/completion/alacritty"

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

  # Pyenv
  if command -v pyenv 1>/dev/null 2>&1; then
   eval "$(pyenv init -)"
  fi
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"


# Alma
  be(){ sudo -u "$1" -i; }
  complete -W "mgr op proc root" be
  alias mgr='be almamgr'
  alias op='be almaop'
  alias proc='be almaproc'
  alias root='be root'
  # With a tmux singleton, like it or not
  alias acse2='tmux rename-window ACSE2; ssh -X mtourneb@acse2-gns.sco.alma.cl -t "source ./.bash_profile; ./.local/bin/tmux new-session -A -s tin"'
  alias ape2='tmux rename-window APE2; ssh -X mtourneb@ape2-gns.osf.alma.cl -t "source ./.bash_profile; ./.local/bin/tmux new-session -A -s tin"'


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

  # Perl
  export PATH="/home/tourneboeuf/perl5/bin${PATH:+:${PATH}}"
  export PERL5LIB="/home/tourneboeuf/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
  export PERL_LOCAL_LIB_ROOT="/home/tourneboeuf/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
  export PERL_MB_OPT="--install_base \"/home/tourneboeuf/perl5\""
  export PERL_MM_OPT="INSTALL_BASE=/home/tourneboeuf/perl5"


# Bind
  # Enable Readline not waiting for additional input when a key is pressed.
  set keyseq-timeout 10
  bind -x '"\ee":fzf_open'
  bind -x '"\er":fzf_dir ~/wiki/rosetta/Lang'
  bind -x '"\eh":fzf_dir .'
  bind -x '"\el":fzf_line .'


# Fast
  # Add "substitute" mnemonic, which the info file left out.
  export PATH="/home/tourneboeuf/Program/GitFuzzy/bin:$PATH"
