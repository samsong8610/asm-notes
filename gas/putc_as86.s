;
; put a character using bios interrupt
;
; as86 -0 -b putc_as86 -o putc_as86.o putc_as86.s
;

	USE16 586
	.text
	entry main
main:
	cli
	mov ax, #0x0E61
	int #0x10
	hlt
	.org 510
	.word 0xAA55
