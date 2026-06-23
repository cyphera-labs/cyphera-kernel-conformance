#!/usr/bin/env bash
# Builds and boots the blockdev_ext4_rw workload with a virtio-blk ext4 disk, checking for the BLOCKDEV_RW_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd blockdev_ext4_rw
DISK_IMG=/tmp/cyphera-blockdev_ext4_rw-disk.img boot_and_check blockdev_ext4_rw BLOCKDEV_RW_OK
