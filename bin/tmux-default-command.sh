#!/bin/sh
if [ ! -z $ENABLED_REATTACH ]; then
    reattach-to-user-namespace -l $SHELL
else
    $SHELL
fi
