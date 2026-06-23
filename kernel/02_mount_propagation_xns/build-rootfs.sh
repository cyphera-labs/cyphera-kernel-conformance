#!/usr/bin/env bash
# Builds the mount_propagation_xns rootfs: stages test.sh and compiles the static bare_unshare shim.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
mkdir -p "$ROOTFS"

cp "$SCRIPT_DIR/test.sh" "$ROOTFS/test.sh"
chmod +x "$ROOTFS/test.sh"

echo "==> building bare_unshare shim"
mkdir -p "$ROOTFS/usr/bin"
cc -static -nostdlib -no-pie -fno-asynchronous-unwind-tables \
    -Wa,--noexecstack "$SCRIPT_DIR/bare_unshare.S" \
    -o "$ROOTFS/usr/bin/bare_unshare"
strip --strip-all "$ROOTFS/usr/bin/bare_unshare"

source "$(dirname "$0")/../../common/build-busybox-rootfs.sh"
