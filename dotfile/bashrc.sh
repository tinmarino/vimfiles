#!/usr/bin/env bash
# BashRc by Tinmarino

# shellcheck disable=SC1091  # Not following

# Clause In {{{1
# If not running interactively, don't do anything
[[ -z "$PS1" ]] && return

# Goto home, not /
if [[ "$PWD" == / ]] ; then cd "$HOME" || : ; fi

# Set USER
[[ -z "$USER" ]] && command -v whoami > /dev/null && USER=$(whoami) && export USER

# Source common (Alma) config
# shellcheck disable=SC1091  # Not following: /etc/bashrc
[[ -e /etc/bashrc ]] && source /etc/bashrc

# Execute tmux {{{1
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


# Internal util {{{1
try_source(){ [[ -f "$1" ]] && source "$1"; }

# Appearance and Header {{{1
# I wanted to be an artists
# clear
# Nowrap
printf '\e[?7l'
cat << 'EOF'
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

export H=$h
export V=$v
export OS=$os

# Man
if [[ ! "$USER" == "jim" ]]; then
  export PAGER="vman"
fi
#export TEXMFHOME="$HOME/Program/Tlmgr"


# Variables Bash {{{1
# Enable directory with $
# shopt -s direxpand
# Avoid c-s freezing
stty -ixon

# Vi as default `git commit`
export EDITOR='vim'
# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Permit ** to expand
shopt -s globstar

# History
# Append instead of overwrite
export HISTSIZE=1000000
export HISTFILESIZE=2000000
export HISTTIMEFORMAT='%Y-%m-%dT%H:%M:%S '
shopt -s histappend
#export HISTCONTROL=ignoredups

# Function {{{1
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
  [[ tourny == "$HOSTNAME" ]] && return 1
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
      pipe-pane -o \"$pipe_pane_cmd\" \; \
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
      [[ -z "$func" ]] && func=MAIN
      local linen="${BASH_LINENO[$(( i - 1 ))]}"
      local src="${BASH_SOURCE[$i]}"
      [[ -z "$src" ]] && src=non_file_source

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
    echo "$(( i_cnt++ ))/ $s_arg!"
  done
}
export -f print_args

command_not_found_handle() {
  # Command not found handle Callback for Unknown command
  # If starting with g : git
  if [[ -n "$1" ]] && [[ "${1:0:1}" == "g" ]]; then
    # shellcheck disable=SC2086
    echo git "${1:1}" $2
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

urlencode(){
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

urldecode(){
  # Usage: urldecode "string"
  : "${1//+/ }"
  printf '%b\n' "${_//%/\\x}"
}

unhexify(){
  : 'Convert hex string (arg1) to binary stream (stdout): see README'
  escaped='' rest="$(IFS=; echo "$*")"
  while [ -n "$rest" ]; do
    tail="${rest#??}"
    escaped="$escaped\\$(printf "%o" 0x"${rest%"$tail"}")"
    rest="$tail"
  done
  printf "$escaped"
}

restart_ollama(){
  sudo systemctl stop ollama.service
  sudo rmmod -f nvidia_uvm && sudo modprobe nvidia_uvm  # Restart driver
  sudo systemctl start ollama.service
}

print_dic(){
  local -n dict=$1
  for key in "${!dict[@]}"; do echo "$key: ${dict[$key]}"; done
}

urldecode(){
  # Tk Moises Castillo
  python3 -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()))"
}

urlencode(){
  python3 -c "import sys; from urllib.parse import quote_plus; print(quote_plus(sys.stdin.read()))"
}



# Fzf functions {{{1
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
  --bind ctrl-space:toggle-preview  # Space => Change all
  --bind ctrl-j:down
  --bind ctrl-k:up
  --bind ctrl-u:half-page-up     # Up
  --bind ctrl-d:half-page-down   # Down
  --bind ctrl-s:toggle-sort      # Sort
  --bind ctrl-g:replace-query    # Get
  --bind alt-u:preview-half-page-up    # Up previw (alt)
  --bind alt-d:preview-half-page-down  # Down previw (alt)
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


# Include, Source, Extension (Alias and Completion) {{{1
############
# Completion
#   maybe source "$HOME/.local/usr/share/bash-completion/bash_completion"
[[ -f "/etc/bash_completion" ]] && source "/etc/bash_completion"

# Alias
[[ -f "$HOME/.bash_aliases.sh" ]] && source "$HOME/.bash_aliases.sh"

# Fzf bindings
# Warning on termux, comment $HOME/Program/Fzf/shell/completion.bash
try_source "$HOME/.vim/bin/fzf_bash_completion"
try_source "$HOME/.vim/bin/fzf_bash_keybindings"

# Rust
try_source "$HOME/.cargo/env"



# Include completion {{{1
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


# Path {{{1
# My script
[[ -n "$PATH" ]] \
  && PATH="$HOME/.cargo/bin:$PATH" \
  || PATH="$HOME/.cargo/bin" \
PATH="$HOME/Bin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.vim/bin:$PATH"
# IRM
PATH+=:"$HOME/Software/Bash/LibDispatch"
PATH+=:"$HOME/Program/Dragons/gempy/scripts"
PATH+=:"$HOME/Program/Dragons/recipe_system/scripts"
PATH+=:"$HOME/Program/idafree-8.3"
PATH+=:"$HOME/go/bin"
PATH+=:"$HOME/Dreamlab/Pentest"
PATH+=:"/usr/local/texlive/2025/bin/x86_64-linux"

MANPATH+=/usr/local/texlive/2025/texmf-dist/doc/man
INFOPATH+=/usr/local/texlive/2025/texmf-dist/doc/info


# Bind {{{1
# Enable Readline not waiting for additional input when a key is pressed.
set keyseq-timeout 10
bind -x '"\ef\ef":fzf_open'

bind -x '"\ee":fzf_open'
bind -x '"\er":fzf_dir ~/wiki/rosetta/Lang'
bind -x '"\eh":fzf_dir .'
bind -x '"\el":fzf_line .'


# Alma {{{1
# Set completion
export ALMASW=~/AlmaSw
complete -o nosort -C tin tin
complete -o nosort -C ./dispatch ./dispatch
complete -o nosort -C dispatch dispatch
complete -C remove_plugin remove_plugin
if (( 1 == B_IS_ALMA )); then
  PATH=/alma/ste/bin:$PATH
  PATH=/usr/X11R6/bin:$PATH
  PATH=/usr/X11R6/bin:$PATH
  #grep(){
  #  ### Shadow the /alma/ste/etc/almaEnv slow Hi
  #  ### Catch grep --color=auto -q i, to make believe I am not interactive
  #  if (( $# == 3 )) && [[ "$2" == "-q" ]] && [[ "$3" == "i" ]]; then
  #    return 1
  #  fi
  #  command grep "$@"; return $?
  #}
  try_source /etc/bashrc
  try_source /alma/ste/etc/defaultEnv
  unset -f grep
else
  # TODO temporary, this is because I am loosing my history
  # Backup history
  # Pyenv
  if command -v pyenv 1>/dev/null 2>&1; then
   eval "$(pyenv init -)"
  fi
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
fi


# PS1 And PROMPT_COMMAND {{{1
# PS1, set in bashrc because debian update it in /etc/bashrc

# PROMPT
# Save history after each executed line
[[ -n "$PROMPT_COMMAND" ]] && [[ "${PROMPT_COMMAND: -1}" != ";" ]] && PROMPT_COMMAND+=";" # Alma fix
export PROMPT_COMMAND+='history -a;'
PROMPT_COMMAND+='fc -ln -1 | trim_space >> ~/.bash_history_save;'

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/' 2> /dev/null | tr -d '\n';
}
export -f parse_git_branch

export PS1=''
# PS1 = Host | PWD | GIT | STATUS | NEWLINE
# Save status
PS1+='$(STATUS=$?; '
# Print Hostname maybe
# CD (green)
PS1+='printf "\[\e[32m\]"; printf "${PWD/#$HOME/\~}"; '
# Git Branch (yellow)
PS1+='printf "\[\e[33m\]"; parse_git_branch; '
# Exit status (blue)
PS1+='printf "\[\e[34m\]"; printf " [$STATUS]"; '
# End color
PS1+='printf "\[\e[0m\]"; '
# New line
PS1+='printf "\n$ "; )'
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


# Fast {{{1
# Add "substitute" mnemonic, which the info file left out.
export PATH="$HOME/Program/GitFuzzy/bin:$PATH"
PATH+=":$HOME/Program/Casa/casa-6.2.1-7-pipeline-2021.2.0.128/bin"


export CVSROOT=:pserver:almasci@cvs01.osf.alma.cl:2401/project21/CVS

PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
#PERL_MB_OPT='--install_base "$HOME/perl5"'; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env


export PATH+=:$HOME/Program/Eso/install/bin

# Fast Mano
s_cli_list="help print_database add_employee remove_employee get_employee list_employees add_job remove_job get_job list_jobs add_department remove_department get_department list_departments last_employee last_job last_department debug_print_employee" 

alias cli="wine bin/labhr_database_cli.exe"
complete -W "$s_cli_list" wine
complete -W "$s_cli_list" cli
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
alias feroxburster="~/Program/Feroxburster/feroxbuster --extract-links --user-agent Dreamlab-Martin-Tourneboeuf"


try_source ~/.vim/bin/rc/complete_shellgpt.sh
try_source ~/Secret/env.sh
# vim: sw=2:ts=2:fdm=marker
try_source "$HOME/.cargo/env"
export PYTHONPATH=/home/mtourneboeuf/Software/Python/CountryStudy
export PYTHONPATH+=:/home/mtourneboeuf/Software/Python/Recon
export ELASTIC_API_KEY="amhqcGc1UUJLSG5PcXRjb19odW06b1FJSk5rd2hRREt4QnR6UkQwQ3Vzdw=="
alias apktool='java -jar ~/Iso/Jar/apktool_2.11.1.jar'
