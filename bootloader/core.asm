[ORG 0]
[BITS 16]

    mov ax, cs
    mov ds, ax
    xor ax, ax
    mov ss, ax

    cli
    lgdt[gdtr]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp $ + 2
    nop
    nop

    db 0x66
    db 0x67
    db 0xEA
    dd pm_start + 0x10000
    dw 0x8

[BITS 32]
pm_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov ecx, msg + 0x10000
    mov eax, msg_len
    call print

    jmp $

print:
    push edx
    push ebx
    xor edx, edx
    xor ebx, ebx
    
print_loop:
    mov dh, byte [ecx + ebx]
    mov byte [0xb8000 + ebx * 2], dh
    mov byte [0xb8000 + ebx * 2 + 1], 0xb
    add ebx, 1
    dec eax
    jnz print_loop
    pop ebx
    pop edx
    ret

gdtr:
    dw gdt_end - gdt_start - 1
    dd gdt_start + 0x10000

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

msg db " _  _  _  _  _  _                                                               "
    db "| \| |/ _ \| |/ /                                                               "
    db "| .` | (_) | ' <                                                                "
    db "|_|\_|\___/|_|\_\                                                               "
msg_len equ $ - msg

times 5120 - ($ - $$) db 0x00
