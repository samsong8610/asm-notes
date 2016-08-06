CC=gcc
LD=ld
CFLAGS=-g -c -m32
LDFLAGS=-melf_i386

.s.o:
	${CC} ${CFLAGS} -o $@ $<

main.bin: main.o
	${LD} ${LDFLAGS} -o $@ $<

main64.o: main64.s
	${CC} -g -c -o $@ $<

main64.bin: main64.o
	${LD} -o $@ $<

all: main.bin main64.bin

clean:
	rm -f *.o *.bin

.phony: all clean
