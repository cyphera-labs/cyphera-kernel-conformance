#!/usr/bin/env bash
# Shared boot helper that builds initrds and boots workloads under QEMU to check for a serial marker.

set -uo pipefail

# Resolve the kernel ELF path from env override, pinned vendor release, or sibling dev build.
discover_kernel_elf() {
    if [ -n "${CYPHERA_KERNEL_ELF:-}" ]; then
        echo "$CYPHERA_KERNEL_ELF"
        return
    fi
    local repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local pin=""
    [ -f "$repo_root/KERNEL_VERSION" ] && pin="$(tr -d '[:space:]' < "$repo_root/KERNEL_VERSION")"
    for candidate in \
        ${pin:+"$repo_root/vendor/cyphera-kernel-$pin.elf"} \
        "$repo_root"/../cyphera-kernel*/target/x86_64-unknown-none/release/cyphera-kernel; do
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return
        fi
    done
    echo "FATAL: no kernel ELF found. Fetch the pinned release with scripts/fetch-kernel.sh (KERNEL_VERSION=${pin:-unset}), or set CYPHERA_KERNEL_ELF." >&2
    exit 1
}

KERNEL_ELF="$(discover_kernel_elf)"
BOOT_MODE="${CYPHERA_BOOT_MODE:-pvh}"
MACHINE="${CYPHERA_QEMU_MACHINE:-}"
TIMEOUT="${CYPHERA_TIMEOUT:-60}"
VERBOSE="${CYPHERA_VERBOSE:-0}"

if [ -z "$MACHINE" ]; then
    case "$BOOT_MODE" in
        pvh) MACHINE=microvm ;;
        grub) MACHINE=q35 ;;
        *) echo "FATAL: invalid CYPHERA_BOOT_MODE=$BOOT_MODE (want pvh|grub)" >&2; exit 1 ;;
    esac
fi

# Tar the workload's rootfs/ into /tmp/cyphera-<name>-initrd.tar with root ownership.
build_initrd() {
    local name="$1"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    local rootfs="$script_dir/rootfs"
    local initrd="/tmp/cyphera-${name}-initrd.tar"
    if [ ! -d "$rootfs" ]; then
        echo "FATAL: $rootfs does not exist; build the rootfs first" >&2
        exit 1
    fi
    tar --owner=0 --group=0 --numeric-owner -cf "$initrd" -C "$rootfs" .
    echo "$initrd"
}

# Boot the kernel with the workload's initrd and return 0 iff the marker appears in the serial log.
boot_and_check() {
    local name="$1"
    local marker="$2"
    local initrd="/tmp/cyphera-${name}-initrd.tar"
    if [ ! -f "$initrd" ]; then
        echo "FATAL: $initrd not found; call build_initrd first" >&2
        return 1
    fi

    local out
    out="$(mktemp -t "cyphera-${name}-boot.XXXXXX")"
    trap 'rm -f "$out"' RETURN

    local disk_args=()
    if [ -n "${DISK_IMG:-}" ]; then
        disk_args=(-drive "id=cdisk,format=raw,file=$DISK_IMG,if=none"
                   -device virtio-blk-device,drive=cdisk)
    fi

    local rc=0
    case "$BOOT_MODE" in
        pvh)
            timeout "$TIMEOUT" qemu-system-x86_64 \
                -machine "$MACHINE,accel=kvm:tcg,pit=off,pic=off,rtc=off" \
                -cpu max -smp 2 -m 1024M \
                -kernel "$KERNEL_ELF" \
                -initrd "$initrd" \
                "${disk_args[@]}" \
                -nodefaults -no-user-config -no-reboot \
                -serial "file:$out" -display none \
                -device isa-debug-exit,iobase=0xf4,iosize=0x04 \
                -device virtio-rng-device \
                >/dev/null 2>&1; rc=$?
            ;;
        grub)
            local iso="/tmp/cyphera-${name}-iso.iso"
            build_grub_iso_with_initrd "$initrd" "$iso" "$name"
            timeout "$TIMEOUT" qemu-system-x86_64 \
                -M "$MACHINE,accel=kvm:tcg,kernel-irqchip=on" \
                -cpu max -m 1024M \
                -bios /usr/share/ovmf/OVMF.fd \
                -cdrom "$iso" \
                -no-reboot \
                -serial "file:$out" -display none \
                -device virtio-rng-pci \
                >/dev/null 2>&1; rc=$?
            rm -f "$iso"
            ;;
    esac

    if grep -q "$marker" "$out"; then
        if [ "$rc" = 124 ]; then
            echo "FAIL  ($name : $marker seen but VM HUNG — timed out without powering off)"
            return 1
        fi
        echo "PASS  ($name : $marker found)"
        return 0
    fi
    echo "FAIL  ($name : $marker not found)"
    if [ "$VERBOSE" = "1" ]; then
        echo "─── serial log ────────────────────────────────"
        cat "$out"
        echo "─── end serial log ────────────────────────────"
    fi
    return 1
}

# Build a one-shot GRUB ISO that boots the kernel + initrd via multiboot2.
build_grub_iso_with_initrd() {
    local initrd="$1"
    local iso_out="$2"
    local name="$3"
    local stage
    stage="$(mktemp -d -t "cyphera-${name}-iso.XXXXXX")"
    trap "rm -rf $stage" RETURN
    mkdir -p "$stage/boot/grub"
    cp "$KERNEL_ELF" "$stage/boot/cyphera-kernel"
    cp "$initrd" "$stage/boot/initrd.tar"
    cat > "$stage/boot/grub/grub.cfg" <<EOF
serial --unit=0 --speed=115200
terminal_input serial
terminal_output serial
set timeout=1
set default=0
menuentry "Cyphera Kernel + ${name} initrd" {
    multiboot2 /boot/cyphera-kernel
    module2 /boot/initrd.tar initrd
    boot
}
EOF
    grub-mkrescue -o "$iso_out" "$stage" >/dev/null 2>&1
}
