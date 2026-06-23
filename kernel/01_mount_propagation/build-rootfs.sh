#!/usr/bin/env bash
# Builds the mount_propagation rootfs: stages test.sh into the busybox rootfs.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
mkdir -p "$ROOTFS"
cp "$SCRIPT_DIR/test.sh" "$ROOTFS/test.sh"
chmod +x "$ROOTFS/test.sh"
source "$(dirname "$0")/../../common/build-busybox-rootfs.sh"
