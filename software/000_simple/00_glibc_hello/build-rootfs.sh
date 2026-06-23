#!/usr/bin/env bash
# Build the glibc_hello rootfs: compile hello via Docker, stage loader/libc, wire in busybox rootfs.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
CACHE="$SCRIPT_DIR/.cache"
BUILDER_TAG="cyphera-glibc-hello-builder:1"
mkdir -p "$ROOTFS" "$CACHE"

if [ ! -f "$CACHE/hello" ] || [ "$SCRIPT_DIR/Dockerfile" -nt "$CACHE/hello" ] \
   || [ "$SCRIPT_DIR/hello.c" -nt "$CACHE/hello" ]; then
    docker build -t "$BUILDER_TAG" "$SCRIPT_DIR"
    cid=$(docker create "$BUILDER_TAG")
    docker cp "$cid:/out/." "$CACHE/"
    docker rm "$cid" >/dev/null
    chmod +x "$CACHE/hello" "$CACHE/ld-linux-x86-64.so.2"
fi

cp "$SCRIPT_DIR/test.sh" "$ROOTFS/test.sh"; chmod +x "$ROOTFS/test.sh"
cp "$CACHE/hello" "$ROOTFS/hello"; chmod +x "$ROOTFS/hello"
mkdir -p "$ROOTFS/lib64" "$ROOTFS/lib/x86_64-linux-gnu" "$ROOTFS/usr/lib/x86_64-linux-gnu"
cp "$CACHE/ld-linux-x86-64.so.2" "$ROOTFS/lib64/ld-linux-x86-64.so.2"
cp "$CACHE/libc.so.6"            "$ROOTFS/lib/x86_64-linux-gnu/libc.so.6"
cp "$CACHE/libc.so.6"            "$ROOTFS/usr/lib/x86_64-linux-gnu/libc.so.6"
source "$SCRIPT_DIR/../../../common/build-busybox-rootfs.sh"
