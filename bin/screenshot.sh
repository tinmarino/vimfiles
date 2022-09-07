#!/bin/bash
: 'Take screenshot <= Binded to print key
  1. Install gnome-screenshot
  2. Run gnome-control-center  # Same as settings
  3. Choose keyboard settings (view and customize ..)
  4. Choose screenshot
  5. Disable print + atl-print + shift-print
  6. Select the Custom Shortcuts
  From: https://cialu.net/how-to-change-default-gnome-screenshot-savings-folder/
'

declare -g OUT_DIR=$HOME/Images/Screenshot

[[ ! -d "$OUT_DIR" ]] && mkdir -p "$OUT_DIR"

# ssfull script <- PrtScr
ssfull(){
  local date=$(date +%Y-%m-%d-%H_%M_%S)
  echo "saving to $OUT_DIR/Screenshot-$date.png"
  gnome-screenshot -f "$OUT_DIR/Screenshot-$date.png"
}

# sswin script <- Alt+PrtScr
sswin(){
  local date=$(date +%Y-%m-%d-%H_%M_%S)
  gnome-screenshot -w -f "$OUT_DIR/Screenshot-$date.png"
}

# ssarea script <- Shift+PrtScr
ssarea(){
  local date=$(date +%Y-%m-%d-%H_%M_%S)
  gnome-screenshot -a -f "$OUT_DIR/Screenshot-$date.png"
}

case "$1" in
  ssfull)
    ssfull
    ;;
  sswin)
    sswin
    ;;
  ssarea)
    ssarea
    ;;
esac
