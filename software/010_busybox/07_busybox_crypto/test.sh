#!/bin/sh
# Exercises busybox md5sum/sha256sum hashing applets and prints BUSYBOX_CRYPTO_OK.

ok=1
chk() { if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 want[$2] got[$3]"; ok=0; fi }

# Known-answer test: digests of the literal string "hello" (no trailing newline).
chk "md5sum hello"    "5d41402abc4b2a76b9719d911017c592" \
    "$(busybox printf hello | busybox md5sum | busybox awk '{print $1}')"
chk "sha256sum hello" "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824" \
    "$(busybox printf hello | busybox sha256sum | busybox awk '{print $1}')"

if [ "$ok" = 1 ]; then echo BUSYBOX_CRYPTO_OK; else echo BUSYBOX_CRYPTO_FAIL; fi
