#!/usr/bin/env bash
# Boot Alpine running a `postgres --single` SQL smoke and check for the PSQL_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export CYPHERA_TIMEOUT="${CYPHERA_TIMEOUT:-240}"
source "$SCRIPT_DIR/../../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd postgres
boot_and_check postgres PSQL_OK
