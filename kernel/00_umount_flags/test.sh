#!/bin/sh
# In-guest test of umount2 flag semantics: plain umount, EBUSY-on-busy, MNT_DETACH, MNT_FORCE, UMOUNT_NOFOLLOW.
set -u
PASS=1
fail() { echo "FAIL: $*"; PASS=0; }

MNT_DETACH=2
MNT_FORCE=1
UMOUNT_NOFOLLOW=8

# Calls the static umount2 helper with a path and flags.
umount2() {
    /usr/bin/umount2 "$1" "$2"
    return $?
}

busybox mkdir -p /uf_unused
busybox mount -t tmpfs tmpfs /uf_unused
if ! busybox umount /uf_unused; then
    fail "1. plain umount of unused mount should succeed"
fi
echo "1. plain umount of unused mount: OK"

busybox mkdir -p /uf_busy
busybox mount -t tmpfs tmpfs /uf_busy
busybox touch /uf_busy/held
exec 9< /uf_busy/held
if busybox umount /uf_busy 2>/dev/null; then
    fail "2. expected EBUSY on umount of mount with open fd, got success"
fi
echo "2. plain umount of busy mount: EBUSY OK"
exec 9<&-
if ! busybox umount /uf_busy; then
    fail "2b. umount should succeed after fd is closed"
fi
echo "2b. plain umount after fd close: OK"

busybox mkdir -p /uf_detach
busybox mount -t tmpfs tmpfs /uf_detach
busybox sh -c 'echo HELLO_DETACH > /uf_detach/file'
exec 9< /uf_detach/file
if ! umount2 /uf_detach $MNT_DETACH; then
    fail "3. MNT_DETACH on busy mount should succeed"
fi
busybox mount -t tmpfs tmpfs /uf_detach
if busybox test -f /uf_detach/file; then
    fail "3b. /uf_detach/file should be empty after re-mount post-detach"
fi
echo "3. MNT_DETACH lazy unmount: OK"
busybox umount /uf_detach 2>/dev/null
read_via_fd9=$(busybox cat <&9 2>/dev/null)
exec 9<&-
if [ "$read_via_fd9" != "HELLO_DETACH" ]; then
    fail "3c. open fd after MNT_DETACH should still read original content; got: $read_via_fd9"
fi
echo "3c. open fd survives MNT_DETACH: OK"

busybox mkdir -p /uf_force
busybox mount -t tmpfs tmpfs /uf_force
busybox touch /uf_force/held
exec 9< /uf_force/held
if ! umount2 /uf_force $MNT_FORCE; then
    fail "4. MNT_FORCE on busy mount should succeed"
fi
exec 9<&-
echo "4. MNT_FORCE on busy mount: OK"

busybox mkdir -p /uf_real
busybox mount -t tmpfs tmpfs /uf_real
busybox ln -s /uf_real /uf_link
if umount2 /uf_link $UMOUNT_NOFOLLOW; then
    fail "5. UMOUNT_NOFOLLOW should refuse symlink target"
fi
echo "5. UMOUNT_NOFOLLOW rejects symlink target: OK"
busybox rm /uf_link
busybox umount /uf_real

if [ "$PASS" = "1" ]; then
    echo UMOUNT_FLAGS_OK
fi
