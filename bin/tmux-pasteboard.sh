#!/bin/sh
if [ `uname` = "Darwin" ] && [ -x ~/bin/tmux-pasteboard ]; then
    ~/bin/tmux-pasteboard -l $SHELL
fi
