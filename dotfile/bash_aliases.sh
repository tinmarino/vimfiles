# Varaible
  export bin="$HOME/.vim/bin"
  export t="$HOME/wiki/todo"
  export v="$HOME/.vim"
  export w="$HOME/wiki/wiki"

# Shortcut
  # Languages
  alias py='python3'
  alias ipy='ipython3'
  alias vi="vim"
  alias pl="perl"

  # Small as Huffman
  alias g='git'
  alias v='vim'
  alias w='vi -c"normal ,ww"'
  alias t='vi -c"normal ,tt"'
  alias o='xdg-open'
  alias c="clip"
  alias disas='objdump -drwC -Mintel'
  alias ll='ls -lh'
  alias h="history|grep "
  alias f="find . |grep "


# Shortcut largers
  # Bigger for memory
  alias open='xdg-open'
  alias clip="xclip -selection c"

  # Utils
  alias clean_tex='rm *.aux *.log *.fls *.fdb_latexmk *.out *synctex.gz'

  # Safe RM
  export TRASH="$HOME/.Trash"
  alias rm="mv -f -t $TRASH"
  alias rmv='rm'

  # CD ..
  alias p='cd ..'
  alias pp='cd ../..'
  alias ppp='cd ../../..'
  alias pppp='cd ../../../..'
  alias ppppp='cd ../../../../..'
  alias pppppp='cd ../../../../../..'

  # Tipo
  alias gerp='grep'
  alias grpe='grep'

# Color improve (ls, grep)
  if [ -x /usr/bin/dircolors ]; then
      test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
      alias ls='ls --color=auto'
      #alias dir='dir --color=auto'
      #alias vdir='vdir --color=auto'

      alias grep='grep --color=auto'
      alias fgrep='fgrep --color=auto'
      alias egrep='egrep --color=auto'
  fi


# Utils
  # Extract
  function extract () {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1    ;;
             *.tar.gz)    tar xvzf $1    ;;
             *.bz2)       bunzip2 $1     ;;
             *.rar)       unrar x $1       ;;
             *.gz)        gunzip $1      ;;
             *.tar)       tar xvf $1     ;;
             *.tbz2)      tar xvjf $1    ;;
             *.tgz)       tar xvzf $1    ;;
             *.zip)       unzip $1       ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1        ;;
             *)           echo "don't know how to extract '$1'..." ;;
         esac
     else
         echo "'$1' is not a valid file!"
     fi
  }
  # Dropbox
  alias dropbox='~/.dropbox-dist/dropboxd $'

  # Battery
  alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage'

  # Diskspace
  alias diskspace="du -S | sort -n -r |more"


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
    ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
  }
  alias m="mark"
  alias ms="marks"
  alias j="jump"


