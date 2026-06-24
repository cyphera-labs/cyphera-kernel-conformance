#!/bin/sh
# Exercises busybox filesystem applets (mkdir/cp/stat/chmod/ln/mv/rm) and prints BUSYBOX_FS_OK.

ok=1
chk() { if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 want[$2] got[$3]"; ok=0; fi }

busybox mkdir /tmp/bb
busybox touch /tmp/bb/a
busybox touch /tmp/bb/b
busybox cp /tmp/bb/a /tmp/bb/copy
chk "cp present"     "1" "$(busybox test -f /tmp/bb/copy && echo 1)"
chk "stat exists"    "1" "$(busybox stat /tmp/bb/a >/dev/null && echo 1)"
busybox chmod 755 /tmp/bb/a
busybox chmod 600 /tmp/bb/copy
chk "chmod 755"      "755" "$(busybox stat -c '%a' /tmp/bb/a)"
chk "chmod 600"      "600" "$(busybox stat -c '%a' /tmp/bb/copy)"
busybox chown 0:0 /tmp/bb/a
chk "chown 0:0"      "0 0" "$(busybox stat -c '%u %g' /tmp/bb/a)"
busybox ln -s /tmp/bb/a /tmp/bb/link
chk "readlink"       "/tmp/bb/a" "$(busybox readlink /tmp/bb/link)"
busybox mv /tmp/bb/copy /tmp/bb/renamed
chk "mv: src gone"   "1" "$(busybox test ! -e /tmp/bb/copy && echo 1)"
chk "mv: dst there"  "1" "$(busybox test -f /tmp/bb/renamed && echo 1)"
busybox rm /tmp/bb/a /tmp/bb/b /tmp/bb/renamed /tmp/bb/link
chk "rm cleared"     "1" "$(busybox test -z "$(busybox ls /tmp/bb)" && echo 1)"
busybox rmdir /tmp/bb
chk "rmdir"          "1" "$(busybox test ! -e /tmp/bb && echo 1)"

if [ "$ok" = 1 ]; then echo BUSYBOX_FS_OK; else echo BUSYBOX_FS_FAIL; fi
