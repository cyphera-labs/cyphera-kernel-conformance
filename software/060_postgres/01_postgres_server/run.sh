#!/usr/bin/env bash
# Boot Alpine running a TCP postgres postmaster + psql query and check for the PG_SERVER_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export CYPHERA_TIMEOUT="${CYPHERA_TIMEOUT:-300}"
source "$SCRIPT_DIR/../../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd postgres_server
boot_and_check postgres_server PG_SERVER_OK
