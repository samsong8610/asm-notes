AS=nasm
LD=ld
CFLAGS=-g
LDFLAGS=

all: boot.elf boot.bin

%.o: %.s
	$(AS) $(CFLAGS) -f elf -F dwarf -o $@ $<

boot.elf: boot.o
	$(LD) $(LDFLAGS) -Ttext=0x7C00 -melf_i386 -o $@ $<

boot.bin: boot.s
	$(AS) -f bin -o $@ $<

clean:
	rm -f *.o *.elf *.bin

.phony: all clean
