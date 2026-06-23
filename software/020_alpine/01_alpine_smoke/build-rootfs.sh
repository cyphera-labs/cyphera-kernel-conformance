#!/usr/bin/env bash
# Build the alpine_smoke rootfs: stock Alpine via apk.static, busybox-init inittab running cyphera-smoke.sh.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
source "$SCRIPT_DIR/../../../common/build-alpine-rootfs.sh"

build_alpine_rootfs "$ROOTFS"

ln -sf /bin/busybox "$ROOTFS/sbin/init"
cat > "$ROOTFS/etc/inittab" <<'EOF'
::sysinit:/bin/busybox mount -t proc proc /proc
::sysinit:/bin/busybox mount -t sysfs sysfs /sys
::sysinit:/bin/busybox mount -t devtmpfs dev /dev
::sysinit:/bin/sh /cyphera-smoke.sh
EOF
install -m755 "$SCRIPT_DIR/cyphera-smoke.sh" "$ROOTFS/cyphera-smoke.sh"

echo "==> alpine_smoke rootfs ready (stock Alpine, busybox-init, no Docker)"
