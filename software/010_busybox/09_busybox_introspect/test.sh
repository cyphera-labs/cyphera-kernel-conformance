#!/bin/sh
# Reads /proc/self entries via busybox and prints BUSYBOX_INTROSPECT_OK.

ok=1
chk() { if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 want[$2] got[$3]"; ok=0; fi }

# cmdline is NUL-separated argv of the reading process: `busybox cat /proc/self/cmdline`.
chk "cmdline argv0" "busybox" \
    "$(busybox cat /proc/self/cmdline | busybox tr '\0' '\n' | busybox head -1)"
# comm is the command name of the reading process (the busybox applet).
chk "comm"          "busybox" "$(busybox cat /proc/self/comm)"
# status must report the process name and a head of fields.
chk "status Name"   "busybox" "$(busybox cat /proc/self/status | busybox head -5 | busybox awk '/^Name:/{print $2}')"
chk "status lines"  "5"       "$(busybox cat /proc/self/status | busybox head -5 | busybox wc -l)"
# /proc/self must expose the standard entries we just read.
chk "ls has comm"   "1"       "$(busybox ls /proc/self | busybox grep -qx comm && echo 1)"
chk "ls has status" "1"       "$(busybox ls /proc/self | busybox grep -qx status && echo 1)"
chk "ls has cmdline" "1"      "$(busybox ls /proc/self | busybox grep -qx cmdline && echo 1)"

if [ "$ok" = 1 ]; then echo BUSYBOX_INTROSPECT_OK; else echo BUSYBOX_INTROSPECT_FAIL; fi
