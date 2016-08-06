LD=ld
AS=nasm

.PHONY: all, clean

all: boot.img boot.elf

clean:
	rm -f *.o *.elf *.img

boot.o: boot.s
	${AS} -f elf -F dwarf -o $@ $<

boot.img: boot.s
	${AS} -f bin -o $@ $<

boot.elf: boot.o
	${LD} -Ttext=0x7c00 -melf_i386 -o $@ $<
