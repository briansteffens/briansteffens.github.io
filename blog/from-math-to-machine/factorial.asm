global _start

section .text

; Calculates the factorial of the value in rax and returns the result in rdi.
factorial:
    mov rdi, 1

  .loop:
    cmp rax, 1
    jle .done

    imul rdi, rax
    dec rax

    jmp .loop

  .done:
    ret


_start:
    ; Call factorial with an input parameter of 5.
    mov rax, 5
    call factorial

    ; Exit program, returning value in rdi as the exit status code.
    mov rax, 60
    syscall
