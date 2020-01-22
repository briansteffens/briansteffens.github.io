org 0x7C00

%define VGA_SEGMENT 0xA000

%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

%define BLUE 1
%define GREEN 2


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
    mov byte [di], GREEN

infinite_loop:
    jmp infinite_loop


times 510-($-$$) db 0
db 0x55, 0xAA
