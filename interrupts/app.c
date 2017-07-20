void main(void) {
    /*
      print 'A' endless
    */
    char c = 'A';
    int count = 0;
    while (1) {
        asm volatile (
            "\tmov $0x07, %%ah\n"
            "\tint $0x21"
            ::"a"(c)
        );
        if (++count == 80) {
            if (++c > 'z') {
                c = 'A';
            }
            count = 0;
        }
    }
}