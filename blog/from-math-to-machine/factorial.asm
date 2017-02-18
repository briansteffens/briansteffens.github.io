global _start

section .text

; Calculates the factorial of the value in rax and returns the result in rdi.
factorial:
    cmp rax, 0
    je base_case

    push rax

    dec rax
    call factorial

    pop rax
    imul rdi, rax

    ret

  base_case:
    mov rdi, 1
    ret


_start:
    ; Call factorial with an input parameter of 5.
    mov rax, 5
    call factorial

    ; Exit program, returning value in rdi as the exit status code.
    mov rax, 60
    syscall
