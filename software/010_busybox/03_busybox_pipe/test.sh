#!/bin/sh
# Runs many piped busybox commands in a loop and prints BUSYBOX_PIPE_OK.

for _ in 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0; do
    busybox seq 1 5 | busybox wc -l
done
echo BUSYBOX_PIPE_OK
