# NOTICE

cyphera-kernel-conformance
Copyright 2026 Horizon Digital Engineering LLC

Licensed under the Apache License, Version 2.0. See
[LICENSE](LICENSE) for the full text.

## Third-party software referenced (not distributed)

The Dockerfiles in this repo fetch the following third-party
software from its upstream source for use as test fixtures. Each
piece retains its own upstream license. This repo orchestrates the
build but does not include or distribute any of these binaries —
they are fetched at build time from their canonical sources.

Every package the build scripts install via `apk add` on the `alpine:3.20`
base retains its own upstream license, as recorded in Alpine's package
index. The table names the fixtures central to each workload; it is not
exhaustive of every transitive Alpine package.

| Software | Upstream license | Source |
|---|---|---|
| Alpine Linux (alpine:3.20 base; alpine-baselayout, openrc, etc.) | various (alpine-baselayout: GPL-2.0-only; openrc: BSD-2-Clause; many more) | https://alpinelinux.org/ |
| busybox / busybox-static (via Alpine) | GPL-2.0-only | https://busybox.net/ |
| musl libc (via Alpine) | MIT | https://musl.libc.org/ |
| bash (via Alpine) | GPL-3.0-or-later | https://www.gnu.org/software/bash/ |
| GNU C Library / glibc — loader + `libc.so.6`, compiled on `debian:bookworm-slim` | LGPL-2.1-or-later (with GPL-licensed components) | https://www.gnu.org/software/libc/ |
| crun (via Alpine) | GPL-2.0-or-later AND LGPL-2.1-or-later | https://github.com/containers/crun |
| Redis (redis-server, Alpine 3.20 → redis 7.2.x) | BSD-3-Clause | https://redis.io/ |
| SQLite (sqlite3) | Public domain | https://sqlite.org/ |
| PostgreSQL (postgresql16 via apk) | PostgreSQL License (permissive BSD-like) | https://www.postgresql.org/ |
| stress-ng (via Alpine) | GPL-2.0-or-later | https://github.com/ColinIanKing/stress-ng |

The Dockerfiles and rootfs builders under `software/` are original
orchestration written for this project (Apache-2.0). They contain no
source code from the third-party projects above — they instruct the
Alpine package manager (`apk add`) or Docker build steps to fetch and
extract the relevant binaries.

## Trademarks

"Linux" is a registered trademark of Linus Torvalds.
"Alpine Linux" is a trademark of Alpine Linux Development Team.
"PostgreSQL" is a trademark of the PostgreSQL Global Development
Group.
"Redis" is a registered trademark of Redis Ltd.

All other trademarks are the property of their respective owners.
