CC=gcc
LD=ld
AS86=as86
LD86=ld86
NASM=nasm

.PHONY: all clean

all: hello_world

clean:
	rm -f *.o *.elf *.img
	rm -f hello_world

hello_world.o: hello_world.s
	${CC} -c -o $@ $<

hello_world: hello_world.o
	${LD} -o $@ $<
