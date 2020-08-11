#!/bin/bash
# From: https://cialu.net/how-to-change-default-gnome-screenshot-savings-folder/

OUT_DIR=$HOME/Images/Screenshot

# ssfull script <- PrtScr
ssfull(){
    DATE=$(date +%Y-%m-%d-%H:%M:%S)
    echo saveing to $OUT_DIR/Screenshot-$DATE.png
    gnome-screenshot -f $OUT_DIR/Screenshot-$DATE.png
}

# sswin script <- Alt+PrtScr
sswin(){
    DATE=$(date +%Y-%m-%d-%H:%M:%S)
    gnome-screenshot -w -f $OUT_DIR/Screenshot-$DATE.png
}

# ssarea script <- Shift+PrtScr
ssarea(){
    DATE=$(date +%Y-%m-%d-%H:%M:%S)
    gnome-screenshot -a -f $OUT_DIR/Screenshot-$DATE.png
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
