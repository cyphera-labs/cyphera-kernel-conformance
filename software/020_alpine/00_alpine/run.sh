#!/usr/bin/env bash
# Boot a stock Alpine rootfs through openrc and check for the ALPINE_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export CYPHERA_TIMEOUT="${CYPHERA_TIMEOUT:-180}"
source "$SCRIPT_DIR/../../../common/boot.sh"

"$SCRIPT_DIR/build-rootfs.sh"

build_initrd alpine
boot_and_check alpine ALPINE_OK
