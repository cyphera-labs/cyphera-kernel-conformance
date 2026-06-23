#!/usr/bin/env bash
# Builds the blockdev_ext4_rw rootfs and an ext4 data disk image populated via mke2fs in an alpine container.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
mkdir -p "$ROOTFS"
cp "$SCRIPT_DIR/test.sh" "$ROOTFS/test.sh"; chmod +x "$ROOTFS/test.sh"
source "$SCRIPT_DIR/../../common/build-busybox-rootfs.sh"

DISK=/tmp/cyphera-blockdev_ext4_rw-disk.img
POP="$(mktemp -d)"
echo "hello-from-the-host-disk" > "$POP/hello.txt"
docker run --rm -v "$POP:/pop:ro" -v /tmp:/out alpine:3.20 sh -euc '
  apk add --no-cache e2fsprogs >/dev/null
  rm -f /out/cyphera-blockdev_ext4_rw-disk.img
  # Match the kernel ext4 driver-s supported feature set: no journal, no
  # metadata_csum (CRC32c metadata checksums are not implemented). 4 KiB
  # blocks x 8192 = 32 MiB.
  mke2fs -t ext4 -F -q -b 4096 \
    -O extent,dir_index,64bit,filetype,sparse_super,^has_journal,^metadata_csum \
    -L cypheradata -d /pop /out/cyphera-blockdev_ext4_rw-disk.img 8192
  chmod 0666 /out/cyphera-blockdev_ext4_rw-disk.img
'
rm -rf "$POP"
echo "==> ext4 data disk: $DISK ($(du -h "$DISK" | cut -f1))"
