// Static helper that invokes the umount2 syscall with a path and flags argument.

    .section .text
    .global _start

_start:
    movq    (%rsp), %rax
    cmpq    $3, %rax
    jl      .Lusage

    movq    16(%rsp), %rdi
    movq    24(%rsp), %rsi

    xorq    %r8, %r8

.Lparse_loop:
    movzbq  (%rsi), %rax
    testq   %rax, %rax
    jz      .Lparse_done
    cmpq    $'0', %rax
    jl      .Lusage
    cmpq    $'9', %rax
    jg      .Lusage
    subq    $'0', %rax
    imulq   $10, %r8
    addq    %rax, %r8
    incq    %rsi
    jmp     .Lparse_loop

.Lparse_done:
    movq    %r8, %rsi
    movq    $166, %rax
    syscall
    testq   %rax, %rax
    jns     .Lok

    negq    %rax
    movq    %rax, %rdi
    movq    $60, %rax
    syscall

.Lok:
    movq    $0, %rdi
    movq    $60, %rax
    syscall

.Lusage:
    movq    $1, %rax
    movq    $2, %rdi
    leaq    usage_msg(%rip), %rsi
    movq    $usage_msg_len, %rdx
    syscall

    movq    $2, %rdi
    movq    $60, %rax
    syscall

    .section .rodata
usage_msg:
    .ascii  "usage: umount2 <path> <flags>\n"
    .set    usage_msg_len, . - usage_msg
