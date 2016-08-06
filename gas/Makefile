CC=gcc
LD=ld
AS86=as86
LD86=ld86
NASM=nasm

.PHONY: all, clean

all: hello_world, boot.img, boot.elf

clean:
	rm -f *.o *.elf *.img
	rm -f hello_world
	rm -f boot

hello_world.o: hello_world.s
	${CC} -c -o $@ $<

hello_world: hello_world.o
	${LD} -o $@ $<

boot.o: boot.s
	${NASM} -f elf -F dwarf -o $@ $<

boot.img: boot.s
	${NASM} -f bin -o $@ $<

boot.elf: boot.o
	${LD} -Ttext=0x7c00 -melf_i386 -o $@ $<
