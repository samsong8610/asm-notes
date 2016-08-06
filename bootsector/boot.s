;
; print '!' and loop endless
; This code can only run in real mode
;
; nasm -f elf32 -F dwarf -o boot.o boot.s
;

	BITS 16				; 16 bits real mode
	DATASEG equ 0x07C0		; BIOS load this to 0x7C00,
					; so set DS=0x07C0 to make label msg1 works
	global _start

_start:
	cli				; disable interrupt
.go:
	mov ax, DATASEG			; get current code segment
	mov ds, ax
	mov ss, ax			; set stack to 0x07C0:0xFFFF
	mov sp, 0xFFFF

	mov si, msg1
	call print

	hlt

;
; print: print a string
; input: si - the address of the string to output
;
print:
	mov ah, 0x0E
.char:
	lodsb
	cmp al, 0
	jz .ret
	int 0x10
	jmp .char
.ret:
	ret

msg1:
	DB "Loading system ...", 0x0D, 0x0A

	TIMES 510 - ($ - $$) DB 0
	DW 0xAA55
