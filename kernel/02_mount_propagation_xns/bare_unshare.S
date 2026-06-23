// Calls sys_unshare(CLONE_NEWNS) then execve's argv[1] with argv[1..], with no propagation post-processing.

    .section .text
    .global _start

_start:
    movq    (%rsp), %rax
    cmpq    $2, %rax
    jl      .Lusage

    movq    $272, %rax
    movq    $0x00020000, %rdi
    syscall
    testq   %rax, %rax
    js      .Lunshare_failed

    leaq    16(%rsp), %rsi
    movq    (%rsi), %rdi

    movq    (%rsp), %rdx
    addq    $2, %rdx
    shlq    $3, %rdx
    addq    %rsp, %rdx

    movq    $59, %rax
    syscall

    movq    $1, %rax
    movq    $1, %rdi
    leaq    msg_exec_fail(%rip), %rsi
    movq    $msg_exec_fail_len, %rdx
    syscall
    movq    $60, %rax
    movq    $2, %rdi
    syscall

.Lunshare_failed:
    movq    $1, %rax
    movq    $1, %rdi
    leaq    msg_unshare_fail(%rip), %rsi
    movq    $msg_unshare_fail_len, %rdx
    syscall
    movq    $60, %rax
    movq    $3, %rdi
    syscall

.Lusage:
    movq    $1, %rax
    movq    $1, %rdi
    leaq    msg_usage(%rip), %rsi
    movq    $msg_usage_len, %rdx
    syscall
    movq    $60, %rax
    movq    $4, %rdi
    syscall

    .section .rodata
msg_unshare_fail:
    .ascii  "bare_unshare: unshare(CLONE_NEWNS) failed\n"
    .set    msg_unshare_fail_len, . - msg_unshare_fail

msg_exec_fail:
    .ascii  "bare_unshare: execve failed\n"
    .set    msg_exec_fail_len, . - msg_exec_fail

msg_usage:
    .ascii  "bare_unshare: usage: bare_unshare <prog> [args...]\n"
    .set    msg_usage_len, . - msg_usage
