#!/usr/bin/env bash

# Clause In
  # If not running interactively, don't do anything
  [[ -z "$PS1" ]] && return

  # Goto home, not /
  if [[ "$PWD" == / ]] ; then cd "$HOME" || : ; fi

  # Set USER
  [[ -z "$USER" ]] && command -v whoami > /dev/null && USER=$(whoami) && export USER

  # Source common (Alma) config
  # shellcheck disable=SC1091  # Not following: /etc/bashrc
  [[ -e /etc/bashrc ]] && source /etc/bashrc

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
      export TERM=tmux-256color
    else
      # for ALMA but some glinch in scroll vim
      export TERM=xterm-256color
    fi
    exec env tmux
  fi


# Appearance and Header
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

  # Map color to nicer color scheme (rgb):
  printf '\e]10;rgb:c5/c8/c6\a'  # foreground
  printf '\e]11;rgb:1d/1f/21\a'  # background
  printf '\e]4;1;rgb:cc/66/66\a'  # red
  printf '\e]4;2;rgb:b5/bd/68\a'  # green
  printf '\e]4;3;rgb:f0/c6/74\a'  # yellow
  printf '\e]4;4;rgb:81/a2/be\a'  # blue
  printf '\e]4;5;rgb:b2/94/bb\a'  # magenta
  printf '\e]4;6;rgb:8a/be/b7\a'  # cyan

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
  *)
    export os="unknown"
    export v="$HOME/.vim"
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
  export HISTSIZE=1000000
  export HISTFILESIZE=2000000
  shopt -s histappend
  #export HISTCONTROL=ignoredups
  # Save history after each executed line
  # Alma fix
  [[ -n "$PROMPT_COMMAND" ]] && [[ "${PROMPT_COMMAND: -1}" != ";" ]] && PROMPT_COMMAND+=";"
  export PROMPT_COMMAND+='history -a;'

# Function
  is_in_array(){
    ### Check if arg1 <string> is in rest of args
    ### Ref: https://stackoverflow.com/a/8574392/2544873
    local element match="$1"; shift
    for element; do [[ "$element" == "$match" ]] && return 0; done
    return 1
  }
  export -f is_in_array
  trim_space(){
    ### Usage: echo "   example   string    " | trim_space
    ### From: https://github.com/dylanaraps/pure-bash-bible
    local s=${1:-$(</dev/stdin)}
    s=${s#"${s%%[![:space:]]*}"}
    s=${s%"${s##*[![:space:]]}"}
    printf '%s\n' "$s"
  }
  export -f trim_space
  is_alma(){
    ### Check if current computer is an Alma STE
    local fp_sitename=/alma/ste/etc/sitename
    [[ -f "$fp_sitename" ]] || return 1
    export SITENAME=$(<"$fp_sitename")
    case $SITENAME in
      ACSE*) return 0 ;;
      APE*) return 0 ;;
      TFINT) return 0 ;;
      *) return 1 ;;
    esac
  }
  is_alma;
  # shellcheck disable=SC2181  # Check exit code directly
  (( B_IS_ALMA = ! $? )); export B_IS_ALMA

  alma_connect(){
    tmux rename-window "$1";
    pipe_pane_cmd="exec cat - | \$HOME/.vim/bin/tmux-pipe #{pane_tty} >> \$HOME/tmux.log "
    ssh "$2" -tt "
      source ~/.bashrc;
      ~/.local/bin/tmux new-session -A -s tin \; \
        pipe-pane \"$pipe_pane_cmd\" \; \
        set-hook after-split-window 'pipe-pane \"$pipe_pane_cmd\"' \; \
        set-hook after-new-window 'pipe-pane \"$pipe_pane_cmd\"' \; \
    "
  }

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

  print_args(){
    ### Print argument received with their positional number, for teaching purposes'
    local i_cnt=1
    for s_arg in "$@"; do
      echo "$(( i_cnt++ ))/ $s_arg"
    done
  }
  export -f print_args

  command_not_found_handle() {
    ### Command not found handle Callback for Unknown command (tip: install bash-completion on tmux)
    # If starting with g : git
    if [[ -z "$1" ]] && [[ "${1:0:1}" == "g" ]]; then
      # shellcheck disable=SC2086
      git "${1:1}" $2
    # If some specific binary (debian)
    elif [[ -x /usr/lib/command-not-found ]]; then
      /usr/lib/command-not-found -- "$1"
      return $?
    elif [[ -x /usr/share/command-not-found/command-not-found ]]; then
      /usr/share/command-not-found/command-not-found -- "$1"
      return $?
    # If any shit, echo bash default errmsg
    else
      printf "bash(rc): %s: command not found\n" "$1" 1>&2
      if command -v print_stack &> /dev/null; then
        print_stack ""
      fi
      return 127
    fi
  }
  export -f command_not_found_handle


# Fzf functions
  #_vim_escaped2='let out = map(fzf#vim#_recent_files(), \"substitute(v:val, \\\"\\\\\\\\~\\\", \\\"'$HOME'\\\", \\\"\\\")\")'
  _vim_escaped2='let out = fzf#vim#_recent_files()'
  _fzf_cmds="bash -c \"
    # Vim recents files
    vim -NEs
      +'redir>>/dev/stdout | packadd fzf.vim'
      +'$_vim_escaped2'
      +'echo join(out, \"\\n\")'
      +'redir END | q' | sed -e \"s?$HOME?~?g\" | sed -e \"s/^\\w/.\\/\\0/\";
    # Find files in local directory
    rg --color always --files \".\";
    # cd \\\"$HOME\\\" && rg --color always --files | awk '{print \\\"~/\\\" \\\$0}';
    # cd \\\"$v\\\" && rg --color always --files | awk '{print \\\"$v/\\\" \\\$0}';
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
    --preview \"$v/bin/fzf_preview {}\"
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


# Include, Source, Extension (Alias and Completion)
  try_source(){ [[ -f "$1" ]] && source "$1"; }
  ############
  # Completion
  #   maybe source "$HOME/.local/usr/share/bash-completion/bash_completion"
  [[ -f "/etc/bash_completion" ]] && source "/etc/bash_completion"

  # Alias
  [[ -f "$HOME/.bash_aliases.sh" ]] && source "$HOME/.bash_aliases.sh"

  # Fzf bindings
  # Warning on termux, comment /home/tourneboeuf/Program/Fzf/shell/completion.bash
  [[ -f "$HOME/.fzf.bash" ]] && source "$HOME/.fzf.bash"

  # Rust
  try_source "$HOME/.cargo/env"


# Include completion
  # BaSh completion
  try_source "$v/scripts/bash-completion/bash_completion"

  # Tmux completion
  command -v _get_comp_words_by_ref &> /dev/null && try_source "$v"/scripts/completion/tmux
  # Alacrity Completion
  try_source "$v/scripts/completion/alacritty"

  _pip_completion(){
    mapfile -t COMPREPLY < <( \
      COMP_WORDS="${COMP_WORDS[*]}" \
      COMP_CWORD=$COMP_CWORD \
      PIP_AUTO_COMPLETE=1 $1 2>/dev/null )
  }
  complete -o default -F _pip_completion pip

# Path
  # My script
  [[ -n "$PATH" ]] \
    && PATH=$HOME/.cargo/bin:$PATH \
    || PATH=$HOME/.cargo/bin \
  PATH=$HOME/Bin:$PATH
  PATH=$HOME/.local/bin:$PATH
  PATH=$HOME/.vim/bin:$PATH
  # IRM
  export PATH+=:~/Software/Jenkins/IrmJenkins/script


# Bind
  # Enable Readline not waiting for additional input when a key is pressed.
  set keyseq-timeout 10
  bind -x '"\ee":fzf_open'
  bind -x '"\er":fzf_dir ~/wiki/rosetta/Lang'
  bind -x '"\eh":fzf_dir .'
  bind -x '"\el":fzf_line .'


# Alma
  # Set completion
  complete -C irm irm
  complete -C remove_plugin remove_plugin
  if (( 1 == B_IS_ALMA )); then
    PATH=/alma/ste/bin:$PATH
    PATH=/usr/X11R6/bin:$PATH
    # Shadow the /alma/ste/etc/almaEnv slow Hi
    grep(){
      if (( ${#@} == 2 )) && [[ "$1" == "-q" ]] && [[ "$2" == "i" ]]; then
        return 1
      fi
      command grep "$@"; return $?
    }
    try_source /etc/bashrc
    try_source /alma/ste/etc/defaultEnv
    unset -f grep
  else
    # TODO temporary, this is because I am loosing my history
    # Backup history
    PROMPT_COMMAND+='fc -ln -1 | trim_space >> ~/.bash_history_save;'
    # Pyenv
    if command -v pyenv 1>/dev/null 2>&1; then
     eval "$(pyenv init -)"
    fi
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
  fi


# PS1
  # PS1, set in bashrc because debian update it in /etc/bashrc
  parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/' 2> /dev/null;
  }
  export -f parse_git_branch
  parse_title() {
    local res=""
    # Host
    if [[ "$HOSTNAME" == "tourny" ]] || [[ "$HOSTNAME" == "almatin" ]]; then
      :  #res=''
    else
      res+="<$HOSTNAME>:   "
    fi
    # Pwd
    res+=$(dirs +0)
    echo "$res"
  }
  export -f parse_title

  export PS1=''
  # Title: Host: CD
  PS1='\[\e]0;`parse_title`\007\]'
  # CD (green)
  PS1+='\[\e[32m\]\w '
  # Git Branch (yellow)
  PS1+='\[\e[33m\]`parse_git_branch`'
  # End color
  PS1+='\[\e[0m\]'
  # New line
  PS1+='\n$ '
  if (( 1 == B_IS_ALMA )); then
    # sitename is defined if is_alma
    case "$SITENAME" in
      APE-HIL)
            prefix="\[\033[33m\]${SITENAME}:\[\033[0m\] " ;;  # Orange if APE-HIL
      AP*)  prefix="\[\033[31m\]${SITENAME}:\[\033[0m\] " ;;  # Red if APE
      *)    prefix="\[\033[32m\]${SITENAME}:\[\033[0m\] " ;;  # Green otherwise
    esac
    PS1="${prefix}${PS1#"$prefix"}"
    unset prefix
  fi


# Fast
  # Add "substitute" mnemonic, which the info file left out.
  export PATH="/home/tourneboeuf/Program/GitFuzzy/bin:$PATH"

  urlencode() {
      # Usage: urlencode "string"
      # From: https://github.com/dylanaraps/pure-bash-bible#percent-encode-a-string
      local LC_ALL=C
      for (( i = 0; i < ${#1}; i++ )); do
          : "${1:i:1}"
          case "$_" in
              [a-zA-Z0-9.~_-])
                  printf '%s' "$_"
              ;;
  
              *)
                  printf '%%%02X' "'$_"
              ;;
          esac
      done
      printf '\n'
  }
  
  urldecode() {
      # Usage: urldecode "string"
      : "${1//+/ }"
      printf '%b\n' "${_//%/\\x}"
  }
