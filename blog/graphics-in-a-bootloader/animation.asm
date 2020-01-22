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

    mov si, 0

    ; while (true) {
    while_true:
        ; for (bx = 0; bx < SCREEN_HEIGHT; bx++) {
        mov bx, 0
        .vertical_loop:
            ; for (cx = 0; cx < SCREEN_WIDTH; cx++) {
            mov cx, 0
            .horizontal_loop:
                ; di = cx + (bx * SCREEN_WIDTH)
                mov ax, SCREEN_WIDTH
                mul bx
                add ax, cx
                mov di, ax

                ; Draw pixel
                mov ax, si
                mov byte [di], al

                inc si
                inc cx
                cmp cx, SCREEN_WIDTH
                jl .horizontal_loop
            ; }

            inc bx
            cmp bx, SCREEN_HEIGHT
            jl .vertical_loop
        ; }

        ; Delay
        mov ah, 0x86
        mov cx, 0x0
        mov dx, 0x2fff
        int 0x15

        inc si
        jmp while_true
    ; }


times 510-($-$$) db 0
db 0x55, 0xAA
