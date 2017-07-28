#include "schedule.h"
#include "console.h"

void task1(void);
void task2(void);

void main(void) {
    init_schedule();
    init_console();

    register_task(task1);
    register_task(task2);

    asm volatile ("sti"::);
    /* switch to user mode */
    asm volatile (
        "movl %%esp, %%eax\n\t"
        "pushl $0x17\n\t"
        "pushl %%eax\n\t"
        "pushfl\n\t"
        "pushl $0x0f\n\t"
        "pushl $1f\n\t"
        "iret\n\t"
        "1:\tmov $0x17, %%ax\n\t"
        "mov %%ax, %%ds\n\t"
        "mov %%ax, %%es\n\t"
        "mov %%ax, %%fs\n\t"
        "mov %%ax, %%gs"
        ::
    );
    puts("in main()");

    while (1) /* endless */;
}

/* user task 1 */
void task1(void) {
    while (1) {
        putc('1');
        delay(0x0fff);
    }
}

/* user task 2 */
void task2(void) {
    while (1) {
        putc('2');
        delay(0x0fff);
    }
}