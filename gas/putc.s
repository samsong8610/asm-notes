;org 0x7c00    - remove as it may be rejected when assembling
;                with elf format. We can specify it on command
;                line or via a linker script.
bits 16

; Use a label for our main entry point so we can break on it
; by name in the debugger
main:
    cli
    mov ax, 0x0E61
    int 0x10
    hlt
    times 510 - ($-$$) db 0
    dw 0xaa55
