#!/bin/sh
# Exercises busybox text-processing applets (seq/tr/sort/awk/sed/cut/grep) and prints BUSYBOX_TEXT_OK.

busybox seq 1 5
busybox seq 1 5 | busybox tr '0-9' 'a-j'
busybox seq 5 -1 1 | busybox sort | busybox uniq | busybox wc -l
busybox seq 1 100 | busybox head -3
busybox seq 1 100 | busybox tail -3
busybox seq 1 5 | busybox awk '{print $1*2}'
busybox echo 'foo bar baz' | busybox sed 's/bar/QUX/'
busybox seq 10 12 | busybox cut -c1
busybox echo 'hello' | busybox tr 'a-z' 'A-Z' | busybox rev
busybox echo 'a' > /tmp/x
busybox echo 'b' >> /tmp/x
busybox cat /tmp/x
busybox grep b /tmp/x
busybox rm /tmp/x
echo BUSYBOX_TEXT_OK
