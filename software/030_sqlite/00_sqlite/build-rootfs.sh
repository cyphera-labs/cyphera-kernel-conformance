#!/usr/bin/env bash
# Build the sqlite workload rootfs: stock Alpine + sqlite, planting the boot-time sqlite workload.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
source "$SCRIPT_DIR/../../../common/build-alpine-rootfs.sh"

build_alpine_rootfs "$ROOTFS" sqlite

install -D -m755 "$SCRIPT_DIR/sqlite-workload.start" \
    "$ROOTFS/etc/local.d/zz-sqlite.start"
echo "==> workload planted: /etc/local.d/zz-sqlite.start"
