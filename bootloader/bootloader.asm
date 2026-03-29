[ORG 0x7C00]
[BITS 16]

section .text
    xor ax, ax
    mov ds, ax

    mov ax, 0xB800
    mov es, ax

    mov bx, 0
    mov dx, 12

    lgdt[gdtr]

gdtr:
    dw gdt_end - gdt_start - 1
    dd gdt_start

gdt_start:
    dq 0x0000000000000000

    ; code descriptor
    dw 0xFFFF ; limit
    dw 0x0000 ; base
    db 0x00   ; base
    db 0x9A   ; P, DPL, S, E, DC, RW, A
    db 0xCF   ; G, DB, L, AVL, limit
    db 0x00   ; base

    ; data descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00
gdt_end:

times 510 - ($ - $$) db  0x00

db 0x55
db 0xAA