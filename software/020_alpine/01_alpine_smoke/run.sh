#!/usr/bin/env bash
# Boot a stock Alpine rootfs with busybox-init running cyphera-smoke.sh and check for CY_ALPINE_DONE.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export CYPHERA_TIMEOUT="${CYPHERA_TIMEOUT:-120}"
source "$SCRIPT_DIR/../../../common/boot.sh"

"$SCRIPT_DIR/build-rootfs.sh"

build_initrd alpine_smoke
boot_and_check alpine_smoke CY_ALPINE_DONE
