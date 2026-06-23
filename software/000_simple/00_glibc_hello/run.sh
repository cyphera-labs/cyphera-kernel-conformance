#!/usr/bin/env bash
# Build the glibc_hello rootfs and boot the kernel, checking for the GLIBC_HELLO_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd glibc_hello
boot_and_check glibc_hello GLIBC_HELLO_OK
