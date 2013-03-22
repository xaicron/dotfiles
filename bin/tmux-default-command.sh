#!/bin/sh
if [ `uname` = "Darwin" ]; then
    which reattach-to-user-namespace 2>&1 > /dev/null;
    if [ "$?" = "0" ]; then
        reattach-to-user-namespace -l $SHELL
    fi
else
    $SHELL
fi
