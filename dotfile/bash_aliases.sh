#!/usr/bin/env bash
# Alias definition
#
# shellcheck disable=SC2154  # v is referenced but not assigned
# shellcheck disable=SC2015  # Note that A && B || C is not if-then-else. C may run when A is true

alias bat="PAGER= bat"
# Helper
  function mcomplete_cmd {
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

  function malias {
    # shellcheck disable=SC2139  # This expands when defined => OK
    alias "$1"="$2"
    [[ ! "$os" == "windows" ]] && command -v _completion_loader > /dev/null && _completion_loader "$2"
    fct="$(mcomplete_cmd "$2")"
    [ -n "$fct" ] && complete -F "$fct" "$1" > /dev/null 2>&1
  }



# Shortcut
  # Small as Huffman
  alias h="history | rg "
  malias c clip
  malias f find
  malias g git
  malias m man
  malias o xdg-open
  malias v vim
  malias s sgpt
  malias t translate
  malias x "xsel --input --clipboard"
  alias fr="find . | rg "

  # Little longer
  malias disas 'objdump -drwC -Mintel'
  malias ll 'ls -lh'
  malias gs 'git status'  # Prevent confusion with ghostscript
  malias gc 'git commit -m'  # Prevent confusion with count graph components
  malias so source
  malias ssh 'TMUX= TERM=xterm-256color ssh'
  malias rp realpath
  

  # Languages
  malias fd fdfind
  malias py python3
  malias py2 python2
  malias py3 python3
  malias pl perl
  malias ra 'raku -I.'
  malias terminal 'TMUX= alacritty'
  malias te 'TMUX= alacritty'
  malias terminal_raw 'alacritty'
  malias traw 'alacritty -e env -i INPUTRC= bash --noprofile --norc'
  malias tnotmux 'alacritty'
  malias vi vim
  malias vimm vim
  alias ipy='jupyter-console'
  alias ira='jupyter-console --kernel=raku'
  alias ija='jupyter-console --kernel=java'
  alias rgi='rg -i'
  alias fri='fr -i'

  # ShellGPT
  alias translate='sgpt --model gpt-3.5-turbo-1106 --role Translate <<EOF'

  # Wiki
  # # Completion generated by wiki2html.copy_src
  #function w () { if [[ -z "$1" ]]; then vim -c"call Windex(1)"; else vim -c"call Windex(1)" -c":VimwikiGoto $1"; fi ; }
  #function a () { if [[ -z "$1" ]]; then vim -c"call Windex(3)"; else vim -c"call Windex(3)" -c":VimwikiGoto $1"; fi ; }
  #function t () { if [[ -z "$1" ]]; then vim -c"call Windex(2)"; else vim -c"call Windex(2)" -c":VimwikiGoto $1"; fi ; }
  f="$HOME/wiki/todo/Src/links.txt" ; [ -f "$f" ] && complete -W "$(cat "$f")" t
  f="$HOME/wiki/wiki/Src/links.txt" ; [ -f "$f" ] && complete -W "$(cat "$f")" w

  # New terminal (without tmux)
  alias tnew='TMUX=1 gnome-terminal'

  # TODO traw without any rc for testing

  # Alma
  alias alma_docker='cd ~/Program/Alma/Docker && docker-compose run centos8 bash'

# Fzf
  alias fgl=fzf_git_log
  alias fo=fzf_open
  alias ff=fzf_line
  alias fl=fzf_line
  alias fcd=fzf_cd


# Path variable
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


# Tmux
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
  if command -v dircolors > /dev/null; then
    [[ -r ~/.dircolors ]] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  fi
  malias ls 'ls --color=auto'
  malias grep 'grep --color=auto'


# Utils
  # Dropbox
  alias dropbox='~/.dropbox-dist/dropboxd $'

  # Battery
  alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage'

  # Diskspace
  alias diskspace="du -S | sort -n -r |more"

# Alma
  be(){
    #sudo -u "$1" -i;
    # Rename tmux pane
    if command -v tmux > /dev/null; then
      local title="${1#alma}"
      title="${title^^}"
      #tmux rename-window "$title"
    fi

    # Connect
    ssh "$1@localhost"

    # # Restore tmux auto pane
    # if command -v tmux > /dev/null; then
    #   tmux setw automatic-rename
    # fi
  }
  complete -W "mgr op proc root" be
  alias mgr='be almamgr'
  alias op='be almaop'
  alias proc='be almaproc'
  alias root='be root'
  # With a tmux singleton, like it or not
  #alias acse2='tmux rename-window ACSE2; ssh mtourneb@acse2-gns.sco.alma.cl -t "source ./.bash_profile; ./.local/bin/tmux new-session -A -s tin"'
  # tmux pipe-pane "$(declare -f tmux_pipe); tmux_pipe \"$(tty)\""
  # shellcheck disable=SC2016  # Expressions
  # Alma_connect(){
  #   tmux rename-window "$1";
  #   ssh mtourneb@acse2-gns.sco.alma.cl -tt '
  #     source ./.bash_profile;
  #     ./.local/bin/tmux new-session -A -s tin \; pipe-pane "
  #       ansi=\"\\x1B\\[[0-9;?>]*[mKHhlC]\";
  #       pre=\"$(tty)\";
  #       pre=\${pre##/dev/};
  #       exec cat - | awk -v date=\"\$(date \"+%Y-%m-%dT%H:%M:%S\")\" -v pre=\"\$pre\" -v ansi=\"\$ansi\" '"'"'{
  #         gsub(/\x1B][0-9];/,\"\");
  #         gsub(/\x0d/,\"\");
  #         gsub(ansi,\"\");
  #         print pre \" \" date \" \" \$0
  #       }'"'"' >> \"$HOME\"/Test/tmux.log
  #     "
  #   '
  # }
  alias laptop='alma_connect Laptop localhost'
  alias acse1='alma_connect ACSE1 mtourneb@acse1-gns.sco.alma.cl'
  alias acse2='alma_connect ACSE2 mtourneb@acse2-gns.sco.alma.cl'
  alias ape1='alma_connect APE1 mtourneb@ape1-gns.osf.alma.cl'
  alias ape2='alma_connect APE2 mtourneb@ape2-gns.osf.alma.cl'
  alias hil='alma_connect HIL mtourneb@ape-hil-gns.osf.alma.cl'
  alias tfint='alma_connect HIL mtourneb@tfint-gns.osf.alma.cl'


# Jump marks from http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
  export MARKPATH=$HOME/.marks
  function jump {
    cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
  }
  function mark {
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
  }
  function unmark {
    rm -i "$MARKPATH/$1"
  }
  function marks {
    # shellcheck disable=SC2012  # Use find
    ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
  }
  function find-text {
    find .  -not -path '*/\.*' -type f  -exec grep -Iq . {} \; -print;
  }
  # alias m="mark"
  # alias ms="marks"
  # alias mj="jump"

# Fast
