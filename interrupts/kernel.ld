OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(startup)

SECTIONS {
    .text 0x0 : {
        kernel.o(.text)
    }
    .app.text 0x400 : {
        app.o(.text)
    }
}