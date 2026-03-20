[ORG 0x7C00]
[BITS 16]

section .text
    xor ax, ax
    mov ds, ax

    mov ax, 0xB800
    mov es, ax

    mov bx, 0
    mov dx, 12

loop:
    mov al, [hello + bx]
    mov [es:bx], al
    mov al, [hello + bx + 1]
    mov [es:bx + 1], al
    add bx, 2

    sub dx, 1
    cmp dx, 0
    jne loop

    jmp $

hello db "H", 0xb, "e", 0xb, "l", 0xb, "l", 0xb, "o", 0xb, " ", 0xb, "W", 0xb, "o", 0xb, "r", 0xb, "l", 0xb, "d", 0xb, "!", 0xb

times 510 - ($ - $$) db  0x00

db 0x55
db 0xAA