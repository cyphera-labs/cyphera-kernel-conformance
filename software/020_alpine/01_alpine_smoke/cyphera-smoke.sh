#!/bin/sh
# Run a sequence of stock busybox/musl commands under `set -e` and print CY_ALPINE_DONE on full pass.
set -e
echo CY_ALPINE_BEGIN
echo "release=$(cat /etc/alpine-release)"
uname -a
echo "pwd=$(pwd)"
ls /

echo CY_PIPE_TOKEN | grep CY_PIPE_TOKEN
test "$(echo c b a | tr ' ' '\n' | sort | head -n1)" = a && echo CY_SORT_OK
echo "rootdirs=$(ls / | wc -l)"

i=0; for w in alpha beta gamma; do i=$((i + 1)); echo "loop$i=$w"; done
echo "math=$((6 * 7))"
echo persisted-data > /tmp/cyfile
test "$(cat /tmp/cyfile)" = persisted-data && echo CY_FILE_OK
date >/dev/null 2>&1 && echo CY_DATE_OK || echo CY_DATE_SKIP
head -n1 /etc/passwd | grep -q root && echo CY_PASSWD_OK

test -r /proc/version
test -d /sys/kernel
echo CY_ALPINE_DONE
/bin/busybox poweroff -f 2>/dev/null || /bin/busybox halt -f 2>/dev/null || true
