#!/usr/bin/env bash
# Builds and boots the umount_flags workload, checking for the UMOUNT_FLAGS_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd umount_flags
boot_and_check umount_flags UMOUNT_FLAGS_OK
