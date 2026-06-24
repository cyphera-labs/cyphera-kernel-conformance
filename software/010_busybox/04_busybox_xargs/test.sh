#!/bin/sh
# Exercises busybox xargs with redirected and piped input and prints BUSYBOX_XARGS_OK.

ok=1
chk() { if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 want[$2] got[$3]"; ok=0; fi }

# Sort the basenames so the check is independent of find's traversal order.
srt() { busybox sort | busybox tr '\n' ' ' | busybox sed 's/ $//'; }

busybox mkdir /tmp/x
busybox touch /tmp/x/a /tmp/x/b /tmp/x/c

busybox echo /tmp/x/a > /tmp/in
chk "redir-single"        "a"     "$(busybox xargs -n1 busybox basename < /tmp/in | srt)"

busybox find /tmp/x -type f > /tmp/in
chk "redir-three"         "a b c" "$(busybox xargs -n1 busybox basename < /tmp/in | srt)"

chk "pipe-three-n1"       "a b c" "$(busybox find /tmp/x -type f | busybox xargs -n1 busybox basename | srt)"

chk "pipe-three-batched"  "a b c" "$(busybox find /tmp/x -type f | busybox xargs busybox basename -a | srt)"

if [ "$ok" = 1 ]; then echo BUSYBOX_XARGS_OK; else echo BUSYBOX_XARGS_FAIL; fi
