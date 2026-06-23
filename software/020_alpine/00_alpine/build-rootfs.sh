#!/usr/bin/env bash
# Build the alpine workload's rootfs tree via apk.static and plant the ALPINE_OK openrc marker.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
source "$SCRIPT_DIR/../../../common/build-alpine-rootfs.sh"

build_alpine_rootfs "$ROOTFS" shadow bash util-linux ca-certificates

mkdir -p "$ROOTFS/etc/local.d"
printf '%s\n' \
    '#!/bin/sh' \
    '# cyphera-kernel conformance marker — greped from the serial log.' \
    'echo ALPINE_OK > /dev/console' \
    '# Marker is in; power off so QEMU exits now instead of idling to the' \
    '# timeout (Alpine would otherwise sit respawning gettys).' \
    'sync; poweroff -f' \
    > "$ROOTFS/etc/local.d/zz-alpine-ok.start"
chmod +x "$ROOTFS/etc/local.d/zz-alpine-ok.start"

echo "==> marker planted: /etc/local.d/zz-alpine-ok.start"
