#!/usr/bin/env bash
# Top-level orchestrator that runs every per-workload run.sh and reports a PASS/FAIL/SKIP summary.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

declare -a WORKLOADS
if [ $# -gt 0 ]; then
    WORKLOADS=("$@")
else
    while IFS= read -r runner; do
        d="$(dirname "$runner")"
        WORKLOADS+=("${d#"$REPO_ROOT"/}")
    done < <(find "$REPO_ROOT" -mindepth 2 -name run.sh -type f -perm -u+x | sort)
fi

pass=0
fail=0
skip=0

for w in "${WORKLOADS[@]}"; do
    runner="$REPO_ROOT/$w/run.sh"
    if [ ! -x "$runner" ]; then
        echo "[$w] no run.sh found at $runner; SKIP"
        skip=$((skip+1))
        continue
    fi
    echo "──── $w ───────────────────────────────────────"
    if "$runner"; then
        pass=$((pass+1))
    else
        rc=$?
        if [ "$rc" = "77" ]; then
            skip=$((skip+1))
        else
            fail=$((fail+1))
        fi
    fi
done

echo
echo "═════════════════════════════════════════════════"
echo "workload-test summary: $pass PASS, $fail FAIL, $skip SKIP"
echo "═════════════════════════════════════════════════"

[ "$fail" = "0" ]
