;;
;; Load a simple kernel from disk and switch into protected mode
;; The kernel size must be less than a sector, 512 bytes.
;;

    bits 16             ; bootsect is 16 bits code
    org 0x7c00          ; bios jmp here to run application

welcome:
    mov ah, 0x13        ; write string
    mov al, 0x01        ; string only contains character, update cursor
    mov bh, 0           ; page number
    mov bl, 0x07        ; format, lightgrey font on black background
    mov cx, [welcome_str_len] ; string length
    mov dx, 0           ; start from (0,0)
    mov bp, welcome_str ; string to write
    int 0x10

enable_a20:
    mov ax, 0x2401
    int 0x15

switch_to_protected_mode:
    cli                 ; disable interrupts
    lgdt [gdtr_value]   ; load gdt
    lidt [idtr_value]   ; load idt
    mov eax, cr0        ; enable PE in CR0:0
    or eax, 0x0001
    mov cr0, eax
    jmp 0x08:start      ; goto the new segment at once

start:
    bits 32             ; now we can use 32 bits code
    ; setup data segment
    xor eax, eax
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    ; setup stack
    mov ss, ax
    mov esp, 0x1fffff

    ; say hello from kernel, BIOS service is gone!
    mov esi, hello_kernel_str
    mov edi, 0xb8000
_print:
    mov al, [esi]
    cmp al, 0
    jz endless
    mov ah, 0x9c            ; bg:blue fg:red highlight
    mov [edi], ax
    add edi, 2
    inc esi
    jmp _print

endless:
    jmp endless

    align 8
gdt_start:
    dq 0                    ; null descriptor
    dq 0x00c09a0000000200   ; kernel code segment, base 0x0, limit 2M, DPL=0
    dq 0x00c0920000000200   ; kernel data segment, base 0x0, limit 2M, DPL=0
gdt_end:

gdtr_value:
    dw gdt_start - gdt_end - 1  ; base + limit is the address of the LAST byte, so minus 1
    dd gdt_start

idtr_value:
    dw 0
    dd 0

welcome_str:
    db "Welcome to use protected-mode demo.", 13, 10
welcome_str_len:
    dw welcome_str_len - welcome_str
hello_kernel_str:
    db "Hello, kernel!", 0

    times 510 - ($ - $$) db 0   ; fill the reset of the sector with 0
    dw 0xAA55           ; boot signature