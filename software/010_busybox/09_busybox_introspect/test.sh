#!/bin/sh
# Reads /proc/self entries via busybox and prints BUSYBOX_INTROSPECT_OK.

busybox cat /proc/self/cmdline; echo
busybox cat /proc/self/comm
busybox cat /proc/self/status | busybox head -5
busybox ls /proc/self
echo BUSYBOX_INTROSPECT_OK
