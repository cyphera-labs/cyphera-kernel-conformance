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

## Known REDs

### 20260623 · kernel v0.0.4 · `software/050_redis/00_redis`

Redis completes every operation against the live server — PING, GET/SET,
INCR, lists, sets, a MULTI/EXEC transaction, TTL, and a BGSAVE fork all
succeed — but on `SHUTDOWN` the kernel panics tearing down the TCP sockets:

    KERNEL PANIC: smoltcp .../iface/socket_set.rs:116:
    handle does not refer to a valid socket

The panic kills the VM before the workload's `REDIS_OK` marker prints, so
the workload reports FAIL. Deterministic. The v0.0.2 multi-connection
accept-path stall that previously blocked this workload is fixed; this
socket-teardown panic is the remaining gap. The workload is kept in the
suite unmodified rather than trimmed to hide the gap.

The three PostgreSQL workloads — RED on v0.0.4's predecessors against the
early storage path (initdb's WAL temp write returned EINVAL) — are green on
v0.0.4.
