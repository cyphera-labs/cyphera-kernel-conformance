#!/usr/bin/env bash
# Build the crun_run rootfs: stock Alpine + crun plus a static-busybox OCI test bundle and boot workload.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS="$SCRIPT_DIR/rootfs"
source "$SCRIPT_DIR/../../../common/build-alpine-rootfs.sh"

build_alpine_rootfs "$ROOTFS" crun busybox-static

BUNDLE="$ROOTFS/opt/test-bundle"
mkdir -p "$BUNDLE/rootfs/bin" "$BUNDLE/rootfs/proc" "$BUNDLE/rootfs/sys" \
         "$BUNDLE/rootfs/dev" "$BUNDLE/rootfs/tmp" "$BUNDLE/rootfs/marker"
cp "$ROOTFS/bin/busybox.static" "$BUNDLE/rootfs/bin/busybox"
ln -sf busybox "$BUNDLE/rootfs/bin/sh"
ln -sf busybox "$BUNDLE/rootfs/bin/echo"
ln -sf busybox "$BUNDLE/rootfs/bin/touch"

cat > "$BUNDLE/config.json" <<'JSON'
{
    "ociVersion": "1.0.0",
    "process": {
        "terminal": false,
        "user": { "uid": 0, "gid": 0 },
        "args": ["/bin/sh", "-c", "echo HELLO_FROM_CONTAINER; touch /marker/CRUN_INSIDE_OK"],
        "env": ["PATH=/bin:/usr/bin", "TERM=linux"],
        "cwd": "/"
    },
    "root": { "path": "rootfs", "readonly": false },
    "hostname": "cyphera-container",
    "mounts": [
        { "destination": "/proc", "type": "proc", "source": "proc" },
        { "destination": "/dev", "type": "tmpfs", "source": "tmpfs",
          "options": ["nosuid", "strictatime", "mode=755", "size=65536k"] }
    ],
    "linux": {
        "namespaces": [
            { "type": "pid" }, { "type": "mount" },
            { "type": "ipc" }, { "type": "uts" }
        ]
    }
}
JSON

install -D -m755 "$SCRIPT_DIR/crun-run.start" \
    "$ROOTFS/etc/local.d/zz-crun.start"
echo "==> workload planted: /etc/local.d/zz-crun.start"
