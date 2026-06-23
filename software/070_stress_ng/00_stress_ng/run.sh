#!/usr/bin/env bash
# Boot Alpine running stress-ng across futex/pthread wait+wake paths and check for the STRESS_NG_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export CYPHERA_TIMEOUT="${CYPHERA_TIMEOUT:-180}"
source "$SCRIPT_DIR/../../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd stress_ng
boot_and_check stress_ng STRESS_NG_OK
