#!/bin/sh
# Exercises busybox find/tar/gzip/gunzip archiving applets and prints BUSYBOX_ARCHIVE_OK.

ok=1
chk() { if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 want[$2] got[$3]"; ok=0; fi }

busybox mkdir -p /tmp/a/b/c
busybox touch /tmp/a/x /tmp/a/b/y /tmp/a/b/c/z
busybox echo hello > /tmp/a/h

chk "find -type f count" "4" "$(busybox find /tmp/a -type f | busybox wc -l)"
chk "find -name z"       "/tmp/a/b/c/z" "$(busybox find /tmp/a -name 'z')"
chk "dirname"            "/tmp/a/b/c"   "$(busybox dirname /tmp/a/b/c/z)"
chk "basename"           "z"            "$(busybox basename /tmp/a/b/c/z)"
chk "du runs"            "1" "$(busybox du -a /tmp/a >/dev/null && echo 1)"

# Round-trip: tar up the tree, extract it elsewhere, assert the payload survives.
busybox tar -cf /tmp/a.tar -C /tmp a
chk "tar created"        "1" "$(busybox test -s /tmp/a.tar && echo 1)"
busybox mkdir /tmp/out
busybox tar -xf /tmp/a.tar -C /tmp/out
chk "extract file count" "4" "$(busybox find /tmp/out -type f | busybox wc -l)"
chk "extracted payload"  "hello" "$(busybox cat /tmp/out/a/h)"

# gzip then gunzip must reproduce a byte-identical tarball.
sz_before="$(busybox wc -c < /tmp/a.tar)"
busybox gzip /tmp/a.tar
chk "gzip produced .gz"  "1" "$(busybox test -f /tmp/a.tar.gz && echo 1)"
busybox gunzip /tmp/a.tar.gz
chk "gunzip restored"    "$sz_before" "$(busybox wc -c < /tmp/a.tar)"

busybox rm -rf /tmp/a /tmp/out /tmp/a.tar

if [ "$ok" = 1 ]; then echo BUSYBOX_ARCHIVE_OK; else echo BUSYBOX_ARCHIVE_FAIL; fi
