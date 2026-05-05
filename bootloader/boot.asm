[ORG 0x7C00]
[BITS 16]

    jmp 0:start

start:
    xor ax, ax
    mov ds, ax
    
    mov [bd], dl ; boot drive

read:
    mov ax, 0x1000
    mov es, ax
    mov bx, 0    ; es:bx = 1000:0000

    mov ah, 2    ; read
    mov al, 4    ; sector count
    mov ch, 0    ; cylinder number
    mov cl, 2    ; sector number
    mov dh, 0    ; head number
    mov dl, [bd] ; drive number

    int 0x13
    jc read

    jmp 0x1000:0000

bd db 0

times 510 - ($ - $$) db 0x00

db 0x55
db 0xAA