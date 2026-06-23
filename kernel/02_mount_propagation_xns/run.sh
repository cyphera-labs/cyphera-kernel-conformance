#!/usr/bin/env bash
# Builds and boots the mount_propagation_xns workload, checking for the MOUNT_PROP_XNS_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd mount_propagation_xns
boot_and_check mount_propagation_xns MOUNT_PROP_XNS_OK
