#!/usr/bin/env bash
# Boot Alpine running a redis client/server workload and check for the REDIS_OK marker.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../../common/boot.sh"
"$SCRIPT_DIR/build-rootfs.sh"
build_initrd redis
boot_and_check redis REDIS_OK
