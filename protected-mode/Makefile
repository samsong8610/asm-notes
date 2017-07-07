AS=nasm
OBJS = kernel.o

.PHONY: all run clean
all: run

kernel.bin: kernel.s
	$(AS) -f bin $< -o $@

run: kernel.bin
	echo press Ctrl+Alt+2 to switch to the monitor
	echo use 'quit' to stop the vm
	qemu-system-i386 -drive file=kernel.bin,if=floppy,index=0,format=raw &

clean:
	echo Cleaning...
	rm -fr *.o *.bin