#!/usr/bin/env bash
# Host-side Alpine rootfs builder that bootstraps a bootable Alpine tree via pinned apk.static, rootless.

set -euo pipefail

ALPINE_BRANCH="v3.20"
ALPINE_ARCH="x86_64"
ALPINE_MIRROR="https://dl-cdn.alpinelinux.org/alpine"

APK_TOOLS_APK="apk-tools-static-2.14.4-r1.apk"
APK_TOOLS_SHA="42fe483a9fc4f8b194eb8ba24849ea7dc4f1b60570674c6c319b82a32c65b6e0"
ALPINE_KEYS_APK="alpine-keys-2.4-r1.apk"
ALPINE_KEYS_SHA="3404c993a01fcc9d349a136e9296c0d4a9d74e09a1452de6d19c30599f9f0d8e"

_ALPINE_COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ALPINE_CACHE="$_ALPINE_COMMON_DIR/.cache/alpine-$ALPINE_BRANCH"

# Download (or reuse cached) a pinned apk, verifying its sha256, and echo the cached path.
_fetch_pinned() {
    local apk="$1" sha="$2"
    local dest="$_ALPINE_CACHE/$apk"
    if [ ! -f "$dest" ] || ! echo "$sha  $dest" | sha256sum -c --status; then
        mkdir -p "$_ALPINE_CACHE"
        curl -fsSL -o "$dest" \
            "$ALPINE_MIRROR/$ALPINE_BRANCH/main/$ALPINE_ARCH/$apk"
        echo "$sha  $dest" | sha256sum -c --status \
            || { echo "FATAL: $apk sha256 mismatch (upstream moved? update the pin)" >&2
                 exit 1; }
    fi
    echo "$dest"
}

# Ensure $APK_STATIC and $KEYS_DIR exist in the cache, extracting them from the pinned apks.
_ensure_apk_static() {
    APK_STATIC="$_ALPINE_CACHE/sbin/apk.static"
    KEYS_DIR="$_ALPINE_CACHE/keys"
    [ -x "$APK_STATIC" ] && [ -d "$KEYS_DIR" ] && return

    local tools keys tmp
    tools="$(_fetch_pinned "$APK_TOOLS_APK" "$APK_TOOLS_SHA")"
    keys="$(_fetch_pinned "$ALPINE_KEYS_APK" "$ALPINE_KEYS_SHA")"

    tar -xzf "$tools" -C "$_ALPINE_CACHE" 2>/dev/null || true
    chmod +x "$APK_STATIC"

    tmp="$_ALPINE_CACHE/.keys-extract"
    rm -rf "$tmp" "$KEYS_DIR" && mkdir -p "$tmp" "$KEYS_DIR"
    tar -xzf "$keys" -C "$tmp" 2>/dev/null || true
    find "$tmp" -name '*.rsa.pub' -exec cp -n {} "$KEYS_DIR/" \;
    rm -rf "$tmp"
}

# Produce a bootable Alpine tree at <rootfs-dir> with alpine-base, requested packages, and openrc runlevels.
build_alpine_rootfs() {
    local rootfs="$1"; shift
    _ensure_apk_static

    local apkcache="$_ALPINE_CACHE/pkgcache"
    mkdir -p "$apkcache"
    rm -rf "$rootfs"; mkdir -p "$rootfs"

    echo "==> bootstrapping Alpine $ALPINE_BRANCH into $rootfs (apk.static, rootless)"
    unshare -r bash -uo pipefail -c '
        APK="$1"; KEYS="$2"; ROOT="$3"; CACHE="$4"
        MIRROR="$5"; BRANCH="$6"; ARCH="$7"; shift 7
        "$APK" --keys-dir "$KEYS" --arch "$ARCH" \
            -X "$MIRROR/$BRANCH/main" -X "$MIRROR/$BRANCH/community" \
            --cache-dir "$CACHE" --root "$ROOT" --initdb \
            add alpine-base "$@" || true
        for entry in devfs:sysinit procfs:sysinit sysfs:sysinit \
                     hostname:boot bootmisc:boot \
                     killprocs:shutdown local:default; do
            chroot "$ROOT" rc-update add "${entry%%:*}" "${entry##*:}" \
                >/dev/null 2>&1 || true
        done
    ' _ "$APK_STATIC" "$KEYS_DIR" "$rootfs" "$apkcache" \
        "$ALPINE_MIRROR" "$ALPINE_BRANCH" "$ALPINE_ARCH" "$@" || true

    if [ ! -x "$rootfs/sbin/openrc" ] || [ ! -f "$rootfs/etc/inittab" ]; then
        echo "FATAL: alpine bootstrap incomplete — /sbin/openrc or /etc/inittab missing" >&2
        return 1
    fi

    chmod -R u+rwX "$rootfs"

    echo cyphera > "$rootfs/etc/hostname"
    printf '127.0.0.1\tlocalhost cyphera\n::1\tlocalhost cyphera\n' \
        > "$rootfs/etc/hosts"

    echo "==> rootfs ready: $(du -sh "$rootfs" | cut -f1)"
}

# Wire <test-script> to run once at boot via openrc's local service, logging to console and powering off after.
alpine_local_test() {
    local rootfs="$1" test_script="$2"
    install -D -m755 "$test_script" "$rootfs/opt/workload-test.sh"
    cat > "$rootfs/etc/local.d/zz-workload.start" <<'EOF'
#!/bin/sh
exec > /dev/console 2>&1
trap 'sync; poweroff -f' EXIT
sh /opt/workload-test.sh
EOF
    chmod +x "$rootfs/etc/local.d/zz-workload.start"
}
