# cyphera-kernel-conformance

Out-of-tree workload validation for the
[Cyphera Kernel](https://github.com/cyphera-labs/cyphera-kernel). Each
workload boots a Cyphera Kernel build inside QEMU + KVM with a real-world
piece of software running under it (Alpine + OpenRC, busybox
applet families, OCI runtime via crun, PostgreSQL, Redis, SQLite,
the glibc dynamic linker, mount-namespace propagation, and
more), then asserts each workload's success marker on the serial
log. Run-mode parity with real software is the gate; the suite is
the credibility proof for the kernel's compatibility claims.

Each workload self-contains its boot harness, test script, and
rootfs builder; shared helpers live in `common/` and top-level
orchestration in `scripts/`.

This is the LTP-equivalent for Cyphera Kernel: separate
maintenance cadence, separate release cadence.

## Layout

Tests are grouped into two top-level buckets by **what's under
test**, which also decides how the fixture is produced:

- **`software/`** — *drop-in real-world software.* "Does stock,
  unmodified upstream software boot on this kernel?" The fixture is
  a real upstream artifact; the kernel is the only variable. This is
  the credibility proof and the v1 pass count.
- **`kernel/`** — *custom-compiled ABI / feature probes.* "Does this
  one syscall behaviour (umount2 flags, mount propagation, blockdev
  mount) work?" No stock software isolates a single behaviour, so
  these are bespoke programs compiled from source on purpose. RED /
  forward-looking probes for unlanded features live here too.

Every directory with a `run.sh` is a workload. Each workload
self-contains its boot harness (`run.sh`), test script (`test.sh`),
rootfs builder (`build-rootfs.sh`), and any Dockerfile / init shim
it needs. Shared infrastructure lives in `common/` (the boot helper)
and `scripts/` (top-level orchestration). Within `software/`,
workloads are grouped by family with numeric prefixes that define
run order:

- **`software/000_simple/`** — glibc-dynamic ELF + dynamic-linker
- **`software/010_busybox/`** — busybox applet coverage by family
  (shell, text, pipe, xargs, fs, archive, crypto, proc, introspect),
  run against Alpine's real busybox
- **`software/020_alpine/`** — Alpine + OpenRC boot — the substrate the
  app workloads build on (`apk add <pkg>`)
- **`software/030_sqlite/`** — file-backed SQLite workload
- **`software/040_crun/`** — OCI container run (crun)
- **`software/050_redis/`** — Redis client/server over TCP
- **`software/060_postgres/`** — PostgreSQL (`--single`, real server,
  and postmaster-under-strace)
- **`software/070_stress_ng/`** — stress-ng workload
- **`kernel/`** — `00_umount_flags`, `01_mount_propagation`,
  `02_mount_propagation_xns`, `03_blockdev_ext4_rw`

Run all workloads at once via `./scripts/run-all.sh`, or one at a
time by path, e.g. `./software/010_busybox/00_busybox/run.sh`.
`scripts/run-all.sh` auto-discovers every subdir that has an
executable `run.sh` and runs them in path (numeric) order.

## Usage

Clone this repo as a sibling of your cyphera-kernel checkout:

```
~/workspace/
├── cyphera-kernel/                    (kernel release checkout)
└── cyphera-kernel-conformance/        (this repo)
```

This suite is **pinned to a specific kernel release** — the version
in the `KERNEL_VERSION` file. Fetch that released ELF, then run every
workload:

```
cd cyphera-kernel-conformance
./scripts/fetch-kernel.sh     # downloads vendor/cyphera-kernel-<ver>.elf
./scripts/run-all.sh
```

`common/boot.sh` then uses the pinned `vendor/` ELF automatically, so
results reflect the **shipped** kernel rather than a moving build. To
test a local build instead, set `CYPHERA_KERNEL_ELF`, or drop a sibling
`cyphera-kernel[-dev]` release build (boot.sh falls back to it). The
suite drives the kernel via QEMU + KVM (when available) and asserts
each workload's success marker on the serial log.

Which kernel each release was validated against — and any known
per-kernel failures — is recorded in [COMPATIBILITY.md](COMPATIBILITY.md).

## Third-party software

This repo references upstream third-party software but does not
distribute it. Builds fetch the relevant binaries directly from
their upstream sources. See [NOTICE.md](NOTICE.md) for license
attribution.

## License

Apache License 2.0 — see [LICENSE](LICENSE).

The orchestration scripts in this repo (Dockerfiles, extract
shell scripts) are Apache-2.0. Third-party software the
Dockerfiles fetch retains its own license terms — see
[NOTICE.md](NOTICE.md) for per-package attribution.
