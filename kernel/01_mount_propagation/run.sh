#!/usr/bin/env bash
# Builds and boots the mount_propagation workload, checking for the MOUNT_PROP_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd mount_propagation
boot_and_check mount_propagation MOUNT_PROP_OK
