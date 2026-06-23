#!/bin/sh
# Exercises busybox process/system applets (id/uname/date/env/nice) and prints BUSYBOX_PROC_OK.

busybox id
busybox uname -m
busybox uname -s
busybox uname -n
busybox uname -a
busybox date -u +%s
busybox hostname
busybox whoami
busybox env | busybox head -3
echo my-pid=$$
busybox sleep 0
busybox true; busybox false || echo false-rc
busybox nice -n 5 busybox echo nice-ok
busybox sh -c 'echo nested-pid=$$'
echo BUSYBOX_PROC_OK
