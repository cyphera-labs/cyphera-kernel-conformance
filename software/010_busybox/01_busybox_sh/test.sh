#!/bin/sh
# Exercises busybox sh shell constructs and prints BUSYBOX_SH_OK.

echo hi
pwd
printf 'world %s\n' cyphera
x=42; echo $x
echo ${x}-suffix
if [ 1 -lt 2 ]; then echo lt-ok; fi
if [ -d /tmp ]; then echo dir-ok; fi
if [ -e /bin/busybox ]; then echo file-ok; fi
for i in a b c; do printf '%s ' $i; done; echo
i=0; while [ $i -lt 3 ]; do printf '%s ' w$i; i=$((i+1)); done; echo
case x in a) echo a;; x) echo case-x;; *) echo other;; esac
double() { echo "got=$1"; }; double hello
echo before; (echo subshell); echo after
true && echo and-ok
false || echo or-ok
echo BUSYBOX_SH_OK
