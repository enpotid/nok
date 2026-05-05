[ORG 0]
[BITS 16]

    mov ax, cs
    mov ds, ax
    xor ax, ax
    mov ss, ax

    cli
    lgdt [gdtr]

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

    mov edi, PML4T_ADDR
    mov cr3, edi       ; cr3 lets the CPU know where the page tables are

    xor eax, eax
    mov ecx, SIZEOF_PAGE_TABLE
    rep stosd          ; init 4 page tables (PML4T, PDPT, PDT, PT)
    mov edi, cr3

    mov DWORD [edi], PDPT_ADDR | PT_PRESENT | PT_READABLE ; 0x1 -> 0x1000 (in PML4E, PDPTE...)

    mov edi, PDPT_ADDR
    mov DWORD [edi], PDT_ADDR | PT_PRESENT | PT_READABLE

    mov edi, PDT_ADDR
    mov DWORD [edi], PT_ADDR | PT_PRESENT | PT_READABLE

    mov edi, PT_ADDR
    mov ebx, PT_PRESENT | PT_READABLE
    mov ecx, ENTRIES_PER_PT

.set_entry:
    mov DWORD [edi], ebx
    add edi, SIZEOF_PT_ENTRY
    add ebx, PAGE_SIZE
    loop .set_entry

    mov eax, cr4
    or eax, CR4_PAE_ENABLE
    mov cr4, eax

    mov ecx, EFER_MSR
    rdmsr
    or eax, EFER_LM_ENABLE
    wrmsr

    mov eax, cr0
    or eax, CR0_PG_ENABLE | CR0_PM_ENABLE   ; ensuring that PM is set will allow for jumping
    mov cr0, eax

    lgdt [gdtr_long + 0x10000]
    jmp gdt_long_start.code:lm_start + 0x10000

[BITS 64]
lm_start:
    cli

    mov ax, gdt_long_start.data
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov rcx, msg + 0x10000
    mov rax, msg_len
    call print
    
    jmp $

print:
    push rdx
    push rbx
    xor rdx, rdx
    xor rbx, rbx

.loop:
    mov dh, byte [rcx + rbx]
    mov byte [0xb8000 + rbx * 2], dh
    mov byte [0xb8000 + rbx * 2 + 1], 0xb
    add rbx, 1
    dec rax
    jnz .loop

    pop rbx
    pop rdx
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

PRESENT        equ 1 << 7
NOT_SYS        equ 1 << 4
EXEC           equ 1 << 3
DC             equ 1 << 2
RW             equ 1 << 1
ACCESSED       equ 1 << 0

; Flags bits
GRAN_4K       equ 1 << 7
SZ_32         equ 1 << 6
LONG_MODE     equ 1 << 5

gdtr_long:
    dw gdt_long_end - gdt_long_start - 1
    dd gdt_long_start + 0x10000

gdt_long_start:
    .null: equ $ - gdt_long_start
        dq 0
    .code: equ $ - gdt_long_start
        .Code.limit_lo: dw 0xffff
        .Code.base_lo: dw 0
        .Code.base_mid: db 0
        .Code.access: db PRESENT | NOT_SYS | EXEC | RW
        .Code.flags: db GRAN_4K | LONG_MODE | 0xF
        .Code.base_hi: db 0
    .data: equ $ - gdt_long_start
        .Data.limit_lo: dw 0xffff
        .Data.base_lo: dw 0
        .Data.base_mid: db 0
        .Data.access: db PRESENT | NOT_SYS | RW
        .Data.Flags: db GRAN_4K | SZ_32 | 0xF
        .Data.base_hi: db 0
gdt_long_end:

msg db " _  _  _  _  _  _                                                               "
    db "| \| |/ _ \| |/ /                                                               "
    db "| .` | (_) | ' <                                                                "
    db "|_|\_|\___/|_|\_\                                                               "
msg_len equ $ - msg

CR0_PM_ENABLE equ 1 << 0
CR0_PG_ENABLE equ 1 << 31

EFER_MSR equ 0xC0000080
EFER_LM_ENABLE equ 1 << 8

ENTRIES_PER_PT equ 512
SIZEOF_PT_ENTRY equ 8
PAGE_SIZE equ 0x1000

SIZEOF_PAGE_TABLE equ 4096

PML4T_ADDR equ 0x1000
PDPT_ADDR equ 0x2000
PDT_ADDR equ 0x3000
PT_ADDR equ 0x4000

PT_PRESENT equ 1
PT_READABLE equ 2

CR4_PAE_ENABLE equ 1 << 5
