#!/bin/sh
# In-guest test of cross-namespace mount propagation between a parent and a bare_unshare child sharing a Shared subtree.
set -u
PASS=1
fail() { echo "FAIL: $*"; PASS=0; }

if [ -z "${MP_XNS_ISOLATED:-}" ]; then
    export MP_XNS_ISOLATED=1
    exec /usr/bin/bare_unshare /bin/busybox.static sh /test.sh
fi

busybox mkdir -p /xns
busybox mount -t tmpfs tmpfs /xns
busybox mount --make-shared /xns

/usr/bin/bare_unshare /bin/busybox.static sh -c '
    set -u
    busybox mkdir -p /xns/from_child
    if ! busybox mount -t tmpfs tmpfs /xns/from_child; then
        echo "child: failed to mount tmpfs /xns/from_child"
        exit 11
    fi
    busybox mkdir -p /xns/from_child/marker_from_child
    exit 0
' || fail "child unshare/setup failed (rc=$?)"

if ! busybox test -d /xns/from_child/marker_from_child; then
    fail "marker not visible in parent ns after child mounted under shared subtree"
fi

busybox mkdir -p /xns/parent_pipe
busybox mount -t tmpfs tmpfs /xns/parent_pipe
busybox mkdir -p /xns/parent_pipe/marker_from_parent

/usr/bin/bare_unshare /bin/busybox.static sh -c '
    if ! busybox test -d /xns/parent_pipe/marker_from_parent; then
        exit 12
    fi
    exit 0
'
rc=$?
if [ "$rc" != "0" ]; then
    fail "parent-side install did not appear in newly-unshared child (rc=$rc)"
fi

if [ "$PASS" = "1" ]; then
    echo MOUNT_PROP_XNS_OK
fi
