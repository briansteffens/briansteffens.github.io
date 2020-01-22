; The BIOS will load our binary into memory at address 0x7C00. This tells the
; assembler what offset to use for calculating addresses.
org 0x7C00

;EXECUTABLE_SEGMENT = 0x7C0
%define VGA_SEGMENT 0xA000

%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

%define BLUE 1
%define RED 2


    ; Setup VGA segment
    mov ax, VGA_SEGMENT
    mov ds, ax

    ; Set graphics mode to 13h (320x200, 8-bit color)
    mov ax, 0x13
    int 0x10

    mov di, 5 + (0 * SCREEN_WIDTH)
    mov byte [di], BLUE

    mov di, 6 + (1 * SCREEN_WIDTH)
    mov byte [di], BLUE

    mov di, 7 + (2 * SCREEN_WIDTH)
    mov byte [di], BLUE

    mov di, 319 + (199 * SCREEN_WIDTH)
    mov byte [di], RED

infinite_loop:
    jmp infinite_loop


; Pad out the rest of the binary with 0s to the byte 510.
times 510-($-$$) db 0

; MBR boot signature.
db 0x55, 0xAA
