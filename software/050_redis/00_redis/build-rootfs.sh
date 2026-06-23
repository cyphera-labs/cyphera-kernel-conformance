#!/usr/bin/env bash
# Build the redis workload rootfs: stock Alpine + redis, planting the boot-time client/server workload.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
source "$SCRIPT_DIR/../../../common/build-alpine-rootfs.sh"

build_alpine_rootfs "$ROOTFS" redis

install -D -m755 "$SCRIPT_DIR/redis-workload.start" \
    "$ROOTFS/etc/local.d/zz-redis.start"
echo "==> workload planted: /etc/local.d/zz-redis.start"
