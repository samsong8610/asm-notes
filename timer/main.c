extern unsigned long volatile jiffies;
extern unsigned long volatile pos;

#define putc(c) ({ \
    char v = (c); \
    asm volatile ( \
        "\tmov $0x07, %%ah\n" \
        "\tint $0x21" \
        ::"a"(v) \
    ); \
})

void main(void) {
    char buf[10];   /* max 10 digits */
    unsigned long s;
    int d;
    char *p = buf;
    while (1) {
        if (jiffies > 0 && jiffies % 100 == 0) {
            /* 1s gone */
            s = jiffies / 100;
            do {
                *p++ = 0x30 + (s % 10);
                s /= 10;
            } while (s);
            pos = 0;    /* display from 0,0 */
            while (p != buf) {
                putc(*(--p));
            }
        }
    }
}