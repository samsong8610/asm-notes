AS=as
CC=gcc
NASM=nasm
LD=ld
OBJCOPY=objcopy
LD-SCRIPT=-T kernel.ld
OBJS = kernel.o

.PHONY: all run clean
all: run

%.o: %.s
	$(AS) --32 -g -o $@ $<

main.o: main.c
	$(CC) -m32 -c -g -O0 -nostdinc -nostdlib -o $@ $<

bootsect.bin: bootsect.s
	$(NASM) -f bin $< -o $@

kernel.elf: kernel.o main.o
	$(LD) $(LD-SCRIPT) -nostdinc -o $@ $^

kernel.bin: kernel.elf
	$(OBJCOPY) -O binary $< $@

image: bootsect.bin kernel.bin
	cat bootsect.bin kernel.bin > image

run: image
	echo press Ctrl+Alt+2 to switch to the monitor
	echo use 'quit' to stop the vm
	qemu-system-i386 -drive file=image,if=floppy,index=0,format=raw &

clean:
	echo Cleaning...
	rm -fr *.o *.bin *.elf image