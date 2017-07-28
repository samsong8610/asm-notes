#ifndef __CONSOLE_H
#define __CONSOLE_H

#define CONSOLE_ROWS 25                 /* console rows per screen */
#define CONSOLE_COLS 80                 /* console columns per screen */

void init_console();

int putc(char c);
int puts(const char *s);

int set_position(int row, int col);

#endif