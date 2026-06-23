#!/usr/bin/env bash
# Boot stock Alpine running a file-backed sqlite workload and check for the SQLITE_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd sqlite
boot_and_check sqlite SQLITE_OK
