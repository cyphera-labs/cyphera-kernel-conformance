#!/bin/sh
# Exercises core busybox applets (echo/printf/cat/ls/test) and prints BUSYBOX_OK.
busybox echo "BusyBox core smoke"
busybox printf '%s %s\n' hello world
echo piped | busybox cat
busybox ls -1 /bin | busybox head -n 3
busybox test -x /bin/busybox && busybox echo "busybox present"
echo BUSYBOX_OK
