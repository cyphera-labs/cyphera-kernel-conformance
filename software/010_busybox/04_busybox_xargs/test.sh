#!/bin/sh
# Exercises busybox xargs with redirected and piped input and prints BUSYBOX_XARGS_OK.

busybox mkdir /tmp/x
busybox touch /tmp/x/a /tmp/x/b /tmp/x/c
echo --- redir-single ---
busybox echo /tmp/x/a > /tmp/in
busybox xargs -n1 busybox basename < /tmp/in
echo --- redir-three ---
busybox find /tmp/x -type f > /tmp/in
busybox xargs -n1 busybox basename < /tmp/in
echo --- pipe-three-n1 ---
busybox find /tmp/x -type f | busybox xargs -n1 busybox basename
echo --- pipe-three-batched ---
busybox find /tmp/x -type f | busybox xargs busybox basename -a
echo BUSYBOX_XARGS_OK
