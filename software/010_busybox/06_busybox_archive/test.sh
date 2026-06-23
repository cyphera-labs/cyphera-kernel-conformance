#!/bin/sh
# Exercises busybox find/tar/gzip/gunzip archiving applets and prints BUSYBOX_ARCHIVE_OK.

busybox mkdir -p /tmp/a/b/c
busybox touch /tmp/a/x /tmp/a/b/y /tmp/a/b/c/z
busybox find /tmp/a
busybox find /tmp/a -type f
busybox find /tmp/a -name 'z'
busybox dirname /tmp/a/b/c/z
busybox basename /tmp/a/b/c/z
busybox du -a /tmp/a
busybox echo hello > /tmp/a/h
busybox tar -cf /tmp/a.tar -C /tmp a
busybox ls -l /tmp/a.tar
busybox mkdir /tmp/out
busybox tar -xf /tmp/a.tar -C /tmp/out
busybox find /tmp/out
busybox cat /tmp/out/a/h
busybox gzip /tmp/a.tar
busybox ls /tmp/a.tar.gz
busybox gunzip /tmp/a.tar.gz
busybox ls /tmp/a.tar
busybox rm -rf /tmp/a /tmp/out /tmp/a.tar
echo BUSYBOX_ARCHIVE_OK
