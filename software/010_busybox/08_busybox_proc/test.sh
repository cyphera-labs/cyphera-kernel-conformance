#!/bin/sh
# Exercises busybox process/system applets (id/uname/date/env/nice) and prints BUSYBOX_PROC_OK.

ok=1
chk() { if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 want[$2] got[$3]"; ok=0; fi }

# Guest boots as root in an x86_64 initrd.
chk "id -u (root)"   "0"       "$(busybox id -u)"
chk "whoami"         "root"    "$(busybox whoami)"
chk "uname -m"       "x86_64"  "$(busybox uname -m)"
chk "uname -s"       "Linux"   "$(busybox uname -s)"
chk "uname -n nonempty" "1"    "$([ -n "$(busybox uname -n)" ] && echo 1)"
# `uname -a` is the long form; it must contain the kernel name and machine.
chk "uname -a has Linux"  "1" "$(busybox uname -a | busybox grep -q Linux && echo 1)"
chk "uname -a has x86_64" "1" "$(busybox uname -a | busybox grep -q x86_64 && echo 1)"
# `date -u +%s` must be a positive integer (seconds since epoch).
secs="$(busybox date -u +%s)"
chk "date -u +%s numeric" "1" "$(echo "$secs" | busybox grep -q '^[0-9][0-9]*$' && echo 1)"
chk "hostname nonempty"   "1" "$([ -n "$(busybox hostname)" ] && echo 1)"
chk "env nonempty"        "1" "$([ -n "$(busybox env | busybox head -3)" ] && echo 1)"
busybox sleep 0
chk "sleep 0 rc"          "0" "$(busybox sleep 0; echo $?)"
busybox true
chk "true rc"             "0" "$?"
busybox false
chk "false rc"            "1" "$?"
# `nice` adjusts priority then execs the command; we only assert the command ran.
chk "nice echo"      "nice-ok" "$(busybox nice -n 5 busybox echo nice-ok)"
# `sh -c` runs a fresh shell; strip its PID and assert the literal prefix.
chk "sh -c nested"   "nested-pid=" "$(busybox sh -c 'echo nested-pid=$$' | busybox sed 's/[0-9]*$//')"

if [ "$ok" = 1 ]; then echo BUSYBOX_PROC_OK; else echo BUSYBOX_PROC_FAIL; fi
