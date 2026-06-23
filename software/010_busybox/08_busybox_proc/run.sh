#!/usr/bin/env bash
# Build the busybox_proc rootfs and boot the kernel, checking for the BUSYBOX_PROC_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export CYPHERA_TIMEOUT="${CYPHERA_TIMEOUT:-180}"
source "$SCRIPT_DIR/../../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd busybox_proc
boot_and_check busybox_proc BUSYBOX_PROC_OK
