# Security

`cyphera-kernel-conformance` orchestrates real-world software
fixtures (Alpine, busybox, crun, PostgreSQL, Redis, SQLite,
glibc-dynamic, and more) for use as workload tests against Cyphera
Kernel. **This repo is a test harness, not a deployed product
surface.** Vulnerabilities in the kernel itself live in the kernel
repo's policy — see the [Cyphera Kernel SECURITY.md](https://github.com/cyphera-labs/cyphera-kernel/blob/main/SECURITY.md).

## What this repo IS responsible for

- The **orchestration scripts** that build and boot the workload
  fixtures: `scripts/*`, `common/boot.sh`, each per-workload
  `run.sh` / `build-rootfs.sh` / `test.sh` / Dockerfile.
- The **kernel-side rootfs assembly** logic in each workload's
  `build-rootfs.sh`: arbitrary-command-execution risk if a
  build step trusts unvalidated upstream tarball contents,
  path-traversal risk in tar extraction, container-escape risk
  from misconfigured Docker invocations, and similar.

## What this repo is NOT responsible for

- **Vulnerabilities in the kernel itself.** Report to the kernel
  repo's SECURITY.md.
- **Vulnerabilities in the third-party software** the fixtures
  build (Alpine, busybox, PostgreSQL, etc.). Report upstream
  through each project's own channels. Each fixture's upstream
  is listed in [NOTICE.md](NOTICE.md).
- **Reproducibility of bit-identical workload binaries** —
  Dockerfile build environments are pinned (Alpine 3.20, specific
  package versions) but bit-identical reproducibility of every
  upstream binary is not a defended property here.

## Reporting

Found a vulnerability in this repo's orchestration scripts?
Email `security@horizondigital.dev`, or use GitHub's private
vulnerability reporting on this repository. Please don't open a
public issue for security findings — use one of the private
channels above so we can triage before disclosure.

No bounty program today; thanks + credit on request.
