#!/bin/sh
# Exercises busybox filesystem applets (mkdir/cp/stat/chmod/ln/mv/rm) and prints BUSYBOX_FS_OK.

busybox ls -1 /
busybox mkdir /tmp/bb
busybox touch /tmp/bb/a
busybox touch /tmp/bb/b
busybox cp /tmp/bb/a /tmp/bb/copy
busybox ls /tmp/bb
busybox stat /tmp/bb/a
busybox chmod 755 /tmp/bb/a
busybox chmod 600 /tmp/bb/copy
busybox stat -c '%a %n' /tmp/bb/a /tmp/bb/copy
busybox chown 0:0 /tmp/bb/a
busybox ln -s /tmp/bb/a /tmp/bb/link
busybox readlink /tmp/bb/link
busybox ls -la /tmp/bb
busybox mv /tmp/bb/copy /tmp/bb/renamed
busybox ls /tmp/bb
busybox rm /tmp/bb/a /tmp/bb/b /tmp/bb/renamed /tmp/bb/link
busybox rmdir /tmp/bb
echo BUSYBOX_FS_OK
