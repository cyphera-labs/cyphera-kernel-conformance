#!/usr/bin/env bash
# Downloads the pinned Cyphera Kernel release ELF from a GitHub release into vendor/.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${KERNEL_VERSION:-$(tr -d '[:space:]' < "$ROOT/KERNEL_VERSION")}"
DEST="$ROOT/vendor"
ASSET="cyphera-kernel-${VERSION}.elf"
REPO="${KERNEL_REPO:-cyphera-labs/cyphera-kernel}"

mkdir -p "$DEST"
echo "==> Fetching $ASSET from $REPO release $VERSION"
gh release download "$VERSION" \
    -R "$REPO" \
    -p "$ASSET" \
    -D "$DEST" \
    --clobber

echo "    staged -> $DEST/$ASSET"
echo "    boot.sh will use this automatically (or set CYPHERA_KERNEL_ELF to override)."
