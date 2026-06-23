// Static /sbin/init shim that execve's /bin/busybox.static with argv ["busybox","sh","/test.sh"].

    .section .text
    .global _start

_start:
    movq    $1, %rax
    movq    $1, %rdi
    leaq    banner(%rip), %rsi
    movq    $banner_len, %rdx
    syscall

    movq    $59, %rax
    leaq    path(%rip), %rdi
    leaq    argv(%rip), %rsi
    leaq    envp(%rip), %rdx
    syscall

    movq    $1, %rax
    movq    $1, %rdi
    leaq    fail(%rip), %rsi
    movq    $fail_len, %rdx
    syscall

    movq    $60, %rax
    movq    $1, %rdi
    syscall

    .section .rodata
banner:
    .ascii  "busybox-shim: exec'ing /bin/busybox.static sh /test.sh\n"
    .set    banner_len, . - banner

fail:
    .ascii  "busybox-shim: execve failed\n"
    .set    fail_len, . - fail

path:
    .asciz  "/bin/busybox.static"

arg0:
    .asciz  "busybox"
arg1:
    .asciz  "sh"
arg2:
    .asciz  "/test.sh"

env0:
    .asciz  "PATH=/bin:/sbin"

    .section .data
argv:
    .quad   arg0
    .quad   arg1
    .quad   arg2
    .quad   0
envp:
    .quad   env0
    .quad   0
