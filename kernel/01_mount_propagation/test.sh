#!/bin/sh
# In-guest test of shared-subtree mount propagation: private bind isolation, shared/slave peer-group fan-out, MS_UNBINDABLE, and shared->private->umount.
set -u

PASS=1
fail() { echo "FAIL: $*"; PASS=0; }
expect_exists() {
    if ! busybox test -d "$1"; then fail "$2: expected dir $1"; fi
}
expect_missing() {
    if busybox test -d "$1"; then fail "$2: did not expect dir $1"; fi
}

busybox mkdir -p /mp_priv_a /mp_priv_b
busybox mount -t tmpfs tmpfs /mp_priv_a
busybox mount --bind /mp_priv_a /mp_priv_b
busybox mkdir -p /mp_priv_a/inner /mp_priv_b/inner
busybox mount -t tmpfs tmpfs /mp_priv_a/inner
busybox mkdir -p /mp_priv_a/inner/marker
expect_missing /mp_priv_b/inner/marker "1. private bind leaked sub-mount to peer"
echo "1. private bind isolates sub-mounts: OK"
busybox umount /mp_priv_a/inner 2>/dev/null
busybox umount /mp_priv_b 2>/dev/null
busybox umount /mp_priv_a 2>/dev/null

busybox mkdir -p /mp_sa /mp_sb
busybox mount -t tmpfs tmpfs /mp_sa
busybox mount --make-shared /mp_sa
busybox mount --bind /mp_sa /mp_sb
busybox mkdir -p /mp_sa/sub
busybox mount -t tmpfs tmpfs /mp_sa/sub
busybox mkdir -p /mp_sa/sub/marker_from_a
expect_exists /mp_sb/sub/marker_from_a "2. shared subtree did not fan out"
echo "2. shared subtree fans submount install to peer: OK"

busybox umount /mp_sa/sub
expect_missing /mp_sb/sub/marker_from_a "2b. shared umount did not propagate"
echo "2b. shared subtree fans umount to peer: OK"
busybox umount /mp_sb 2>/dev/null
busybox umount /mp_sa 2>/dev/null

busybox mkdir -p /mp_master /mp_slave
busybox mount -t tmpfs tmpfs /mp_master
busybox mount --make-shared /mp_master
busybox mount --bind /mp_master /mp_slave
busybox mount --make-slave /mp_slave

busybox mkdir -p /mp_master/x
busybox mount -t tmpfs tmpfs /mp_master/x
busybox mkdir -p /mp_master/x/from_master
expect_exists /mp_slave/x/from_master "3a. slave did not receive from master"
echo "3a. master submount propagates to slave: OK"

busybox mkdir -p /mp_slave/y
busybox mount -t tmpfs tmpfs /mp_slave/y
busybox mkdir -p /mp_slave/y/from_slave
expect_missing /mp_master/y/from_slave "3b. slave leaked to master"
echo "3b. slave submount does NOT propagate to master: OK"
busybox umount /mp_slave/y 2>/dev/null
busybox umount /mp_master/x 2>/dev/null
busybox umount /mp_slave 2>/dev/null
busybox umount /mp_master 2>/dev/null

busybox mkdir -p /mp_unbind /mp_unbind_target
busybox mount -t tmpfs tmpfs /mp_unbind
busybox mount --make-unbindable /mp_unbind
if busybox mount --bind /mp_unbind /mp_unbind_target 2>/dev/null; then
    fail "4. bind from MS_UNBINDABLE source should have failed"
    busybox umount /mp_unbind_target 2>/dev/null
else
    echo "4. MS_UNBINDABLE refuses bind source: OK"
fi
busybox umount /mp_unbind 2>/dev/null

busybox mkdir -p /mp_p
busybox mount -t tmpfs tmpfs /mp_p
busybox mount --make-shared /mp_p
busybox mount --make-private /mp_p
if ! busybox umount /mp_p; then
    fail "5. umount after shared->private failed"
else
    echo "5. shared->private->umount cycle: OK"
fi

if [ "$PASS" = "1" ]; then
    echo MOUNT_PROP_OK
fi
