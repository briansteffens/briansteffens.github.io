%define NULL 0

; The BIOS will load our binary into memory at address 0x7C00. This tells the
; assembler what offset to use for calculating addresses.
org 0x7C00

    ; Load the address of the message into `si`.
    mov si, message

print_string:
    ; Load a byte into `al` from the message pointer `si` and advance `si` to
    ; the next byte.
    lodsb

    ; Check for the null-termination character. If found, exit the loop.
    cmp al, NULL
    je infinite_loop

    ; Write the byte in `al` as an ASCII character to the screen.
    mov ah, 0x0E
    int 0x10

    ; Continue the loop.
    jmp print_string

; Loop forever so we don't try to execute the message contents as code.
infinite_loop:
    jmp infinite_loop

; The message to print.
message: db "Hi, I'm a bootloader who doesn't load anything.", `\r`, `\n`, NULL

; Pad out the rest of the binary with 0s to the byte 510.
times 510-($-$$) db 0

; MBR boot signature.
db 0x55, 0xAA
