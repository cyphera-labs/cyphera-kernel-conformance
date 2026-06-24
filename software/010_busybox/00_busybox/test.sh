#!/bin/sh
# Exercises core busybox applets (echo/printf/cat/ls/test) and prints BUSYBOX_OK.

ok=1
chk() { if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 want[$2] got[$3]"; ok=0; fi }

chk "echo"         "BusyBox core smoke" "$(busybox echo "BusyBox core smoke")"
chk "printf"       "hello world"        "$(busybox printf '%s %s\n' hello world)"
chk "cat pipe"     "piped"              "$(echo piped | busybox cat)"
# /bin must list at least three entries; head -n 3 yields exactly 3 lines.
chk "ls | head -3" "3"                  "$(busybox ls -1 /bin | busybox head -n 3 | busybox wc -l)"
busybox test -x /bin/busybox && present="busybox present"
chk "test -x"      "busybox present"    "$present"

if [ "$ok" = 1 ]; then echo BUSYBOX_OK; else echo BUSYBOX_FAIL; fi
