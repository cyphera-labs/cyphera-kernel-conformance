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
    '# cyphera-kernel conformance marker. Assert init actually mounted the' \
    '# GLOBAL namespace (proc/sys/dev/run) before declaring success, then' \
    '# print the marker for the serial grep. A tolerated/failed init mount' \
    '# must fail this workload, not slip through as ALPINE_OK.' \
    'ok=1' \
    'for spec in " /proc proc " " /sys sysfs " " /dev devtmpfs " " /run tmpfs "; do' \
    '    grep -q "$spec" /proc/mounts || { echo "  mount MISSING:$spec"; ok=0; }' \
    'done' \
    'if [ "$ok" = 1 ]; then echo ALPINE_OK > /dev/console; else echo "ALPINE_FAIL (init mount gap)" > /dev/console; cat /proc/mounts > /dev/console; fi' \
    '# Power off so QEMU exits now instead of idling to the timeout' \
    '# (Alpine would otherwise sit respawning gettys).' \
    'sync; poweroff -f' \
    > "$ROOTFS/etc/local.d/zz-alpine-ok.start"
chmod +x "$ROOTFS/etc/local.d/zz-alpine-ok.start"

echo "==> marker planted: /etc/local.d/zz-alpine-ok.start"
