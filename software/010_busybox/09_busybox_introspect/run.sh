#!/usr/bin/env bash
# Build the busybox_introspect rootfs and boot the kernel, checking for the BUSYBOX_INTROSPECT_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export CYPHERA_TIMEOUT="${CYPHERA_TIMEOUT:-180}"
source "$SCRIPT_DIR/../../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd busybox_introspect
boot_and_check busybox_introspect BUSYBOX_INTROSPECT_OK
