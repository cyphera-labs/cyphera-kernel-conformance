#!/bin/sh
# Exercises busybox text-processing applets (seq/tr/sort/awk/sed/cut/grep) and prints BUSYBOX_TEXT_OK.

ok=1
chk() { if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 want[$2] got[$3]"; ok=0; fi }

chk "seq 1 5"       "1 2 3 4 5"   "$(busybox seq 1 5 | busybox tr '\n' ' ' | busybox sed 's/ $//')"
chk "tr 0-9 a-j"    "b c d e f"   "$(busybox seq 1 5 | busybox tr '0-9' 'a-j' | busybox tr '\n' ' ' | busybox sed 's/ $//')"
chk "sort|uniq|wc"  "5"           "$(busybox seq 5 -1 1 | busybox sort | busybox uniq | busybox wc -l)"
chk "head -3"       "1 2 3"       "$(busybox seq 1 100 | busybox head -3 | busybox tr '\n' ' ' | busybox sed 's/ $//')"
chk "tail -3"       "98 99 100"   "$(busybox seq 1 100 | busybox tail -3 | busybox tr '\n' ' ' | busybox sed 's/ $//')"
chk "awk *2"        "2 4 6 8 10"  "$(busybox seq 1 5 | busybox awk '{print $1*2}' | busybox tr '\n' ' ' | busybox sed 's/ $//')"
chk "sed sub"       "foo QUX baz" "$(busybox echo 'foo bar baz' | busybox sed 's/bar/QUX/')"
chk "cut -c1"       "1 1 1"       "$(busybox seq 10 12 | busybox cut -c1 | busybox tr '\n' ' ' | busybox sed 's/ $//')"
chk "tr upper|rev"  "OLLEH"       "$(busybox echo 'hello' | busybox tr 'a-z' 'A-Z' | busybox rev)"
busybox echo 'a' > /tmp/x
busybox echo 'b' >> /tmp/x
chk "cat appended"  "a
b"                                "$(busybox cat /tmp/x)"
chk "grep b"        "b"           "$(busybox grep b /tmp/x)"
busybox rm /tmp/x

if [ "$ok" = 1 ]; then echo BUSYBOX_TEXT_OK; else echo BUSYBOX_TEXT_FAIL; fi
