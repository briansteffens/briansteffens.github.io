org 0x7C00

%define VGA_SEGMENT 0xA000

%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

    ; Setup segments
    mov ax, VGA_SEGMENT
    mov ds, ax

    ; Locate stack after bootloader in memory
    mov ax, 0x7E0
    mov ss, ax

    ; Stack grows upward: allocate 8k for stack.
    mov sp, 0x2000
    mov bp, sp

    ; Set graphics mode to 13h (320x200, 8-bit color)
    mov ax, 0x13
    int 0x10


wait_forever:
    jmp wait_forever


times 510-($-$$) db 0
db 0x55, 0xAA
