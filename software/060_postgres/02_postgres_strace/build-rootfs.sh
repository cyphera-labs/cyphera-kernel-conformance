#!/usr/bin/env bash
# Build the postgres_strace rootfs: stock Alpine + postgresql16 + strace, planting the boot workload.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
source "$SCRIPT_DIR/../../../common/build-alpine-rootfs.sh"
build_alpine_rootfs "$ROOTFS" postgresql16 postgresql16-client strace
install -D -m755 "$SCRIPT_DIR/pg-strace.start" "$ROOTFS/etc/local.d/zz-pg.start"
echo "==> workload planted: /etc/local.d/zz-pg.start"
