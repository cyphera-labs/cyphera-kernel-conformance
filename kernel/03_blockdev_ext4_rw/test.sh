#!/bin/sh
# In-guest test that mounts a virtio-blk ext4 disk read-write, reads a baked-in file, writes a new file, and reads it back.
set -u
PASS=1
fail() { echo "FAIL: $*"; PASS=0; }

busybox mkdir -p /mnt
echo "blockdev: mounting /dev/vda (ext4) read-write"
if ! busybox mount -t ext4 /dev/vda /mnt 2>&1; then
    fail "mount -t ext4 /dev/vda /mnt failed (kernel /dev->BlockDevice hook missing?)"
fi

if [ "$(busybox cat /mnt/hello.txt 2>/dev/null)" = "hello-from-the-host-disk" ]; then
    echo "blockdev: read pre-existing /mnt/hello.txt OK"
else
    fail "could not read pre-existing /mnt/hello.txt off the disk"
fi

if busybox sh -c 'echo written-on-cyphera > /mnt/written.txt' 2>/dev/null; then
    busybox sync
    if [ "$(busybox cat /mnt/written.txt 2>/dev/null)" = "written-on-cyphera" ]; then
        echo "blockdev: write + read-back /mnt/written.txt OK"
    else
        fail "wrote /mnt/written.txt but read-back mismatched"
    fi
else
    fail "write /mnt/written.txt failed"
fi

busybox umount /mnt 2>/dev/null
[ "$PASS" = 1 ] && busybox echo "BLOCKDEV_RW_OK"
