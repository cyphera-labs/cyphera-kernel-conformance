#!/usr/bin/env bash
# Build the stress_ng rootfs by running the Dockerfile builder and unpacking its alpine-stress.tar.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
CACHE="$SCRIPT_DIR/.cache"
BUILDER_TAG="cyphera-stress-ng-builder:1"
mkdir -p "$ROOTFS" "$CACHE"
if [ ! -f "$CACHE/alpine-stress.tar" ] || [ "$SCRIPT_DIR/Dockerfile" -nt "$CACHE/alpine-stress.tar" ] \
   || [ "$SCRIPT_DIR/stress-ng.start" -nt "$CACHE/alpine-stress.tar" ]; then
    docker build -t "$BUILDER_TAG" "$SCRIPT_DIR"
    docker run --rm --user "$(id -u):$(id -g)" -v "$CACHE:/out" "$BUILDER_TAG"
fi
rm -rf "$ROOTFS"; mkdir -p "$ROOTFS"
tar -xf "$CACHE/alpine-stress.tar" -C "$ROOTFS"
chmod -R u+r "$ROOTFS"
du -sh "$ROOTFS"
