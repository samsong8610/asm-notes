void main(void) {
    while (1) {
        asm volatile (
            "\tmov $0x0741, %%ax\n"
            "\tint $0x21"
            ::
        );
    }
}