#!/usr/bin/env bash
# Build the postgres_server rootfs: stock Alpine + postgresql16, planting the boot postmaster workload.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
source "$SCRIPT_DIR/../../../common/build-alpine-rootfs.sh"
build_alpine_rootfs "$ROOTFS" postgresql16 postgresql16-client
install -D -m755 "$SCRIPT_DIR/pg-server.start" "$ROOTFS/etc/local.d/zz-pg.start"
echo "==> workload planted: /etc/local.d/zz-pg.start"
