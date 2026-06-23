#!/bin/sh
# Exercises busybox md5sum/sha256sum hashing applets and prints BUSYBOX_CRYPTO_OK.

busybox printf hello | busybox md5sum
echo md5-ok
busybox printf hello | busybox sha256sum
echo BUSYBOX_CRYPTO_OK
