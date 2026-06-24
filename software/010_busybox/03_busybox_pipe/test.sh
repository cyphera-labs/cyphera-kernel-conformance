#!/bin/sh
# Runs many piped busybox commands in a loop and prints BUSYBOX_PIPE_OK.

ok=1
chk() { if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 want[$2] got[$3]"; ok=0; fi }

n=0
for _ in 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0; do
    # `seq 1 5` produces 5 lines; `wc -l` must report exactly 5 every iteration.
    out="$(busybox seq 1 5 | busybox wc -l)"
    [ "$out" = 5 ] && n=$((n+1))
done
# 50 loop iterations, each must yield the correct line count.
chk "50x seq|wc-l == 5" "50" "$n"

if [ "$ok" = 1 ]; then echo BUSYBOX_PIPE_OK; else echo BUSYBOX_PIPE_FAIL; fi
