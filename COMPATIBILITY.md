# Compatibility

Which Cyphera Kernel each conformance release was validated against, and
any known failures on that kernel.

Conformance releases are dated (`YYYYMMDD`) and version independently of
the kernel — a release is "the suite as run against the kernel named here."
The kernel a checkout is pinned to lives in [`KERNEL_VERSION`](KERNEL_VERSION);
`scripts/fetch-kernel.sh` fetches that exact signed release ELF.

| Conformance release | Kernel validated | Result | Known RED |
|---|---|---|---|
| 20260623 | v0.0.4 | 23 / 24 | `software/050_redis/00_redis` — kernel panic on TCP socket teardown |
| 20260623.1 | v0.0.4 | 23 / 24 | redis — socket-teardown panic; tests hardened |

<!-- next release — uncomment + fill AFTER ./scripts/run-all.sh validates v0.0.5; do not pre-fill the result:
| YYYYMMDD | v0.0.5 | __ / 24 | (none if redis is green; else the workload + one-line cause) |
-->

## Known REDs

### kernel v0.0.4 · `software/050_redis/00_redis`

Redis runs every op, then the kernel panics tearing down its TCP sockets on
shutdown (smoltcp `socket_set.rs:116`), before `REDIS_OK` prints → FAIL.
Deterministic; kept in the suite, not trimmed.
