#!/bin/sh
# Exercises busybox sh shell constructs and prints BUSYBOX_SH_OK.

ok=1
chk() { if [ "$2" = "$3" ]; then echo "  ok: $1"; else echo "  FAIL: $1 want[$2] got[$3]"; ok=0; fi }

chk "echo"          "hi"          "$(echo hi)"
chk "pwd nonempty"  "yes"         "$([ -n "$(pwd)" ] && echo yes)"
chk "printf"        "world cyphera" "$(printf 'world %s\n' cyphera)"
x=42
chk "var expand"    "42"          "$(echo $x)"
chk "brace expand"  "42-suffix"   "$(echo ${x}-suffix)"
if [ 1 -lt 2 ]; then lt=lt-ok; fi
chk "if -lt"        "lt-ok"       "$lt"
if [ -d /tmp ]; then d=dir-ok; fi
chk "if -d"         "dir-ok"      "$d"
if [ -e /bin/busybox ]; then f=file-ok; fi
chk "if -e"         "file-ok"     "$f"
chk "for loop"      "a b c "      "$(for i in a b c; do printf '%s ' $i; done)"
chk "while loop"    "w0 w1 w2 "   "$(i=0; while [ $i -lt 3 ]; do printf '%s ' w$i; i=$((i+1)); done)"
chk "case"          "case-x"      "$(case x in a) echo a;; x) echo case-x;; *) echo other;; esac)"
double() { echo "got=$1"; }
chk "func arg"      "got=hello"   "$(double hello)"
chk "subshell"      "before
subshell
after"             "$(echo before; (echo subshell); echo after)"
chk "&& short"      "and-ok"      "$(true && echo and-ok)"
chk "|| short"      "or-ok"       "$(false || echo or-ok)"

if [ "$ok" = 1 ]; then echo BUSYBOX_SH_OK; else echo BUSYBOX_SH_FAIL; fi
