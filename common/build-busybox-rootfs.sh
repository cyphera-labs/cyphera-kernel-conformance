#!/usr/bin/env bash
# Builds and plants the shared busybox-static binary and /sbin/init shim into a caller-provided $ROOTFS.

set -euo pipefail

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_CACHE="$COMMON_DIR/.cache"
SHARED_BUSYBOX="$COMMON_CACHE/busybox.static"
SHARED_SHIM="$COMMON_CACHE/init-busybox-shim"
BUILDER_TAG="cyphera-busybox-static:1"

mkdir -p "$COMMON_CACHE"

if [ ! -f "$SHARED_BUSYBOX" ]; then
    echo "==> building $BUILDER_TAG from ../busybox/Dockerfile"
    docker build -t "$BUILDER_TAG" "$COMMON_DIR/../busybox"

    echo "==> extracting busybox.static into $COMMON_CACHE/"
    docker run --rm \
        --user "$(id -u):$(id -g)" \
        -v "$COMMON_CACHE:/out" "$BUILDER_TAG"
    chmod +x "$SHARED_BUSYBOX"
fi

SHIM_SRC="$COMMON_DIR/busybox-shim.S"
if [ ! -f "$SHARED_SHIM" ] || [ "$SHIM_SRC" -nt "$SHARED_SHIM" ]; then
    echo "==> building $SHARED_SHIM"
    cc -static -nostdlib -no-pie -fno-asynchronous-unwind-tables \
        -Wa,--noexecstack "$SHIM_SRC" -o "$SHARED_SHIM"
    strip --strip-all "$SHARED_SHIM"
fi

: "${ROOTFS:?ROOTFS must be set by the caller before sourcing this}"
mkdir -p "$ROOTFS/sbin" "$ROOTFS/bin"
cp "$SHARED_SHIM" "$ROOTFS/sbin/init"
cp "$SHARED_BUSYBOX" "$ROOTFS/bin/busybox.static"
ln -sf busybox.static "$ROOTFS/bin/busybox"

echo "==> rootfs ready:"
ls -la "$ROOTFS/sbin/init" "$ROOTFS/bin/busybox.static" "$ROOTFS/test.sh"
du -sh "$ROOTFS"
