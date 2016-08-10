;
; Bootloader program
; Load mini kernel 'head' into memory location 0x10000,
; and then move it to 0x0, run from there in protected mode.
;

	bits 16			; 16 bits real mode
	BOOTSEG equ 0x07c0	; boot segment 0x07c0
	SYSSEG equ 0x1000	; mini kernel load location
	SYSLEN equ 1		; mini kernel max sectors

	global _start

_start:
	mov ax, BOOTSEG		; setup ds and ss
	mov ds, ax
	mov ss, ax
	mov sp, 0x400		; stack top set to 0x07c0:0x400

	; use bios int 0x13 to read mini kernel to 0x10000 segment
	mov ch, 0x0		; track 0, 0-1023
	mov cl, 0x02		; from sector 2, 1-17
	mov dh, 0x0		; head number 0, 0-15
	mov dl, 0x80		; hd 0
	mov ax, SYSSEG		; to segment 0x1000
	mov es, ax
	xor bx, bx
	mov ah, 0x02		; function code 0x02: read disk sectors
	mov al, SYSLEN		; number of sectors to read, 1-128
	int 0x13
	jnc ok_load		; success

	mov al, 0x46		; F - fail
	mov ah, 0x0E		; teletype output
	xor bx, bx		; BH - page number, BL - color
	int 0x10
	jmp $			; endless loop

ok_load:
	mov al, 0x54		; T - success
	mov ah, 0x0E		; teletype output
	xor bx, bx		; BH - page number, BL - color
	int 0x10
	jmp $			; endless loop

	times 510 - ($ - $$) db 0	; fill to 510 with 0
	dw 0xAA55		; boot sector flags

	times 512 db 0x30	; file a sector with '0' for tests
