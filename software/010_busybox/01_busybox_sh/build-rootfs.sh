#!/usr/bin/env bash
# Build a stock Alpine rootfs and wire this workload's test.sh to run at boot.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
source "$SCRIPT_DIR/../../../common/build-alpine-rootfs.sh"
build_alpine_rootfs "$ROOTFS"
alpine_local_test "$ROOTFS" "$SCRIPT_DIR/test.sh"
