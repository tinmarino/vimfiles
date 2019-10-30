#!/bin/sh

cp $HOME/.bash_history $HOME/Documents/History/history_bash_$OS_$(date +%Y_%m_%d_%H_%M_%S).txt
cp $HOME/.tmux_history $HOME/Documents/History/history_tmux_$OS_$(date +%Y_%m_%d_%H_%M_%S).txt
cp /home2/tourneboeuf/.viminfo $HOME/Documents/History/history_viminfo_$OS_$(date +%Y_%m_%d_%H_%M_%S).txt
