bits 16

org 0x7C00

%define CODE_SEGMENT 0x7C0
%define VGA_SEGMENT 0xA000

%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200

%define COLOR_WIDTH 10
%define COLOR_HEIGHT 5

%define SQUARES_HORIZONTAL 5
%define SQUARES_VERTICAL 5

%define BLUE 1
%define GREEN 2
%define CYAN 3

    ; Setup segments
    mov ax, CODE_SEGMENT
    mov ds, ax
    mov cx, ax
    mov es, ax

    ; Locate stack after bootloader in memory
    mov ax, 0x7E0
    mov ss, ax

    ; Stack grows upward: allocate 8k for stack.
    mov sp, 0x2000

    ; Set graphics mode to 13h (320x200, 8-bit color)
    mov ax, 0x13
    int 0x10

    ; si = color
    ;mov si, 0

    ; for (cx = 0; cx < SQUARES_VERTICAL; cx++) {
    ;mov cx, 0
    ;.vertical_loop:

    ;    ; for (bx = 0; bx < SQUARES_HORIZONTAL; bx++) {
    ;    mov bx, 0
    ;    .horizontal_loop:
    ;        push cx
    ;        push bx
    ;        ; draw_rectangle(bx * width, cx * height, width, height, color)
    ;        mov ax, COLOR_WIDTH
    ;        mul bx
    ;        push ax
    ;        mov ax, COLOR_HEIGHT
    ;        mul cx
    ;        push ax
    ;        push COLOR_WIDTH
    ;        push COLOR_HEIGHT
    ;        push si
    ;        ;push BLUE
    ;        call draw_rectangle

    ;        pop bx
    ;        pop cx

    ;        ; Next color
    ;        inc si

    ;        ; Next horizontal square
    ;        inc bx
    ;        cmp bx, SQUARES_HORIZONTAL
    ;        cmp bx, 4
    ;        jl .horizontal_loop
    ;    ; }

    ;    ; Next vertical square
    ;    inc cx
    ;    cmp cx, SQUARES_VERTICAL
    ;    jl .vertical_loop
    ;

;    push 0
;    push 0
;    push 10
;    push 5
;    push BLUE
;    call draw_rectangle
;
;    push 0
;    push 5
;    push 10
;    push 5
;    push GREEN
;    call draw_rectangle
;
;    push 0
;    push 10
;    push 10
;    push 5
;    push CYAN
;    call draw_rectangle


    mov si, BLUE
    push si

    push 0
    push 0
    push 0
    push 0
    push si
    call draw_rectangle

    pop si
    inc si
    push si

    push 1
    push 0
    push 0
    push 0
    push si
    call draw_rectangle

    pop si
    inc si
    push si

    push 2
    push 0
    push 0
    push 0
    push si
    call draw_rectangle

    pop si
    inc si
    push si

    push 3
    push 0
    push 0
    push 0
    push si
    call draw_rectangle


wait_forever:
    jmp wait_forever


; Stack arguments: (left, top, width, height, color)
%define DRAW_RECTANGLE_ARG_LEFT   12
%define DRAW_RECTANGLE_ARG_TOP    10
%define DRAW_RECTANGLE_ARG_WIDTH  8
%define DRAW_RECTANGLE_ARG_HEIGHT 6
%define DRAW_RECTANGLE_ARG_COLOR  4
draw_rectangle:
    push bp
    mov bp, sp

    mov ax, [bp + DRAW_RECTANGLE_ARG_LEFT]
    push ax

    mov ax, [bp + DRAW_RECTANGLE_ARG_TOP]
    push ax

    mov ax, [bp + DRAW_RECTANGLE_ARG_COLOR]
    push ax

    call draw_pixel

    ;; for (cx = top; cx < top + height; cx++) {
    ;mov cx, [bp + DRAW_RECTANGLE_ARG_TOP]
    ;.vertical_loop:

    ;    ; for (bx = left; bx < left + width; bx++) {
    ;    mov bx, [bp + DRAW_RECTANGLE_ARG_LEFT]
    ;    .horizontal_loop:

    ;        ; draw_pixel(bx, cx, color)
    ;        push bx
    ;        push cx
    ;        mov ax, [bp + DRAW_RECTANGLE_ARG_COLOR]
    ;        push ax
    ;        call draw_pixel

    ;        inc bx
    ;        mov ax, [bp + DRAW_RECTANGLE_ARG_LEFT]
    ;        mov dx, [bp + DRAW_RECTANGLE_ARG_WIDTH]
    ;        add ax, dx
    ;        cmp bx, ax
    ;        jl .horizontal_loop
    ;    ; }

    ;    inc cx
    ;    mov ax, [bp + DRAW_RECTANGLE_ARG_TOP]
    ;    mov dx, [bp + DRAW_RECTANGLE_ARG_HEIGHT]
    ;    add ax, dx
    ;    cmp cx, ax
    ;    jl .vertical_loop
    ;; }

    leave
    ret


; Stack arguments: (x coordinate, y coordinate, color)
; Outputs:         None
%define DRAW_PIXEL_ARG_X 8
%define DRAW_PIXEL_ARG_Y 6
%define DRAW_PIXEL_ARG_COLOR 4
draw_pixel:
    push bp
    mov bp, sp
    push di

    ; di = coordinate_to_offset(x, y)
    mov ax, [bp + DRAW_PIXEL_ARG_X]
    push ax
    mov ax, [bp + DRAW_PIXEL_ARG_Y]
    push ax
    call coordinate_to_offset
    mov di, ax

    ; *di = color
    mov ax, VGA_SEGMENT
    mov es, ax

    mov bx, [bp + DRAW_PIXEL_ARG_COLOR]
    mov [es:di], bl

    mov ax, CODE_SEGMENT
    mov es, ax

    pop di
    leave
    ret


; Stack arguments: (x coordinate, y coordinate)
; Outputs:         ax = memory offset
%define COORDINATE_TO_OFFSET_ARG_X 6
%define COORDINATE_TO_OFFSET_ARG_Y 4
coordinate_to_offset:
    push bp
    mov bp, sp
    push cx

    ; ax = y * SCREEN_WIDTH
    mov ax, [bp + COORDINATE_TO_OFFSET_ARG_Y]
    mov cx, SCREEN_WIDTH
    mul cx

    ; ax += x
    mov cx, [bp + COORDINATE_TO_OFFSET_ARG_X]
    add ax, cx

    pop cx
    leave
    ret


times 510-($-$$) db 0
db 0x55, 0xAA
