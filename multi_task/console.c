#include "console.h"

extern unsigned long pos;

void init_console() {
    pos = 0;
}

int putc(char c) {
    asm volatile (
        "\tmov $0x07, %%ah\n"
        "\tint $0x21"
        ::"a"(c)
    );
    return 0;
}

int puts(const char *s) {
    const char *p = s;
    while (*p) {
        putc(*p++);
    }
    return p - s;
}

int set_position(int row, int col) {
    if (row < 0 || row >= CONSOLE_ROWS || col < 0 || col >= CONSOLE_COLS) {
        return -1;
    }
    pos = row * CONSOLE_COLS + col;
    return 0;
}