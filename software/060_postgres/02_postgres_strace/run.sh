#!/usr/bin/env bash
# Boot Alpine running the postgres postmaster under strace and check for the STRACE_PG_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export CYPHERA_TIMEOUT="${CYPHERA_TIMEOUT:-300}"
source "$SCRIPT_DIR/../../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd postgres_strace
boot_and_check postgres_strace STRACE_PG_OK
