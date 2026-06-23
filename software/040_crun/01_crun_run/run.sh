#!/usr/bin/env bash
# Boot Alpine and run an OCI container via crun, checking for the CRUN_RUN_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export CYPHERA_TIMEOUT="${CYPHERA_TIMEOUT:-180}"
source "$SCRIPT_DIR/../../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd crun_run
boot_and_check crun_run CRUN_RUN_OK
