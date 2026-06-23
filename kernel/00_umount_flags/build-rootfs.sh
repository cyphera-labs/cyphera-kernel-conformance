#!/usr/bin/env bash
# Builds the umount_flags rootfs: stages test.sh and compiles the static umount2 helper.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
mkdir -p "$ROOTFS"

cp "$SCRIPT_DIR/test.sh" "$ROOTFS/test.sh"
chmod +x "$ROOTFS/test.sh"

echo "==> building umount2 helper"
mkdir -p "$ROOTFS/usr/bin"
cc -static -nostdlib -no-pie -fno-asynchronous-unwind-tables \
    -Wa,--noexecstack "$SCRIPT_DIR/umount2.S" \
    -o "$ROOTFS/usr/bin/umount2"
strip --strip-all "$ROOTFS/usr/bin/umount2"

source "$(dirname "$0")/../../common/build-busybox-rootfs.sh"
