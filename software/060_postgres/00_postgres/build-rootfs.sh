#!/usr/bin/env bash
# Build the postgres --single smoke rootfs: stock Alpine + postgresql16, planting the boot workload.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
source "$SCRIPT_DIR/../../../common/build-alpine-rootfs.sh"
build_alpine_rootfs "$ROOTFS" postgresql16 postgresql16-client
install -D -m755 "$SCRIPT_DIR/psql-smoke.start" "$ROOTFS/etc/local.d/zz-psql.start"
echo "==> workload planted: /etc/local.d/zz-psql.start"
