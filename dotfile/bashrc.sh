#!/usr/bin/env bash

# Init, Variables
  # If not running interactively, don't do anything
  [[ -z "$PS1" ]] && return

  # Goto home
  if [[ "$PWD" == / ]] ; then cd "$HOME" || : ; fi

  # Set USER
  [[ -z "$USER" ]] && command -v whoami > /dev/null && USER=$(whoami) && export USER


# Profiling
  # https://stackoverflow.com/questions/5014823/how-to-profile-a-bash-shell-script-slow-startup
  #exec 3>&2 2> >( tee /tmp/bash-$$.log |
  #                  sed -u 's/^.*$/now/' |
  #                  date -f - +%s.%N >/tmp/bash-$$.tim)
  #set -x


# Execute tmux
  if command -v tmux &> /dev/null \
      && [[ -z "$TMUX" \
      &&  ! "$TERM" =~ screen  && ! "$TERM" =~ "screen-256color" \
      &&  ! "$TERM" =~ tmux  &&  ! "$TERM" =~ "tmux-256color" ]] \
      ; then
    # for ALMA but some glinch in scroll vim
    # exec env TERM=xterm-256color tmux
    # For bold and italic
    exec env TERM=tmux-256color tmux
  fi


# Head
  #clear
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


# Languages
  # Perl
  export PERL5LIB="$PERL5LIB:$HOME/Program/Perl/Lib/lib/perl5/x86_64-linux-gnu-thread-multi"
  export PERL5LIB="$PERL5LIB:$HOME/Software/Perl/Lib:$HOME/Program/Komodo/Komodo-PerlRemoteDebugging-8.0.2-78971-linux-x86_64"
  export PERL5DB="BEGIN { require q($PERL5LIB/perl5db.pl)}"
  export PERLDB_OPTS="RemotePort=localhost:9000"
  export DBGP_IDEKEY="whatever"

  # Git
  ## Android
  #if [ "$os" = "termux" ] ; then
  #  export GIT_AUTHOR_NAME=tinmux
  #  export GIT_AUTHOR_EMAIL=tin@ter.mux
  ## Windows
  #elif [ "$os" = "windows" ] ; then
  #  export GIT_AUTHOR_NAME=tinwin
  #  export GIT_AUTHOR_EMAIL=tin@win.dows
  ## Linux
  #else
  #  if [ "$USER" = "tourneboeuf" ] ; then
  #    export GIT_AUTHOR_NAME=Tinmarino
  #    export GIT_AUTHOR_EMAIL=tinmarino@gmail.com
  #  elif [ "$USER" = "almamgr" ] ; then
  #    export GIT_AUTHOR_NAME=tinhat
  #    export GIT_AUTHOR_EMAIL=tin@red.hat
  #  else
  #    export GIT_AUTHOR_NAME=$USER
  #    export GIT_AUTHOR_EMAIL=$USER@his.pc
  #  fi
  #fi
  #export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
  #export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"


# Fast
  # man
  export PAGER="vman"
  # complete -cf sudo
  export TEXMFHOME=$HOME/Program/Tlmgr
  # Add "substitute" mnemonic, which the info file left out.
  doc_sed() {
    info sed "Command and Option Index" | \
      sed -n '/\*/s/ s c/ s \(substitute\) c/;s/command[:,].*//p'
  }
  export PATH="/home/tourneboeuf/Program/GitFuzzy/bin:$PATH"

# vim:sw=2:ts=2:foldignore=:
