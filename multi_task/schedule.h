#ifndef __SCHEDULE_H
#define __SCHEDULE_H

#define TASK_NR 3               /* max tasks */
#define TASK_STACK_SIZE 32      /* task stack size */

#define FIRST_TSS_ENTRY 3
#define FIRST_LDT_ENTRY (FIRST_TSS_ENTRY + 1)
#define _TSS(n) ((((unsigned long) (n)) << 4) + (FIRST_TSS_ENTRY << 3))
#define _LDT(n) ((((unsigned long) (n)) << 4) + (FIRST_LDT_ENTRY << 3))

/**
 * segment descriptor definition
 */
struct descriptor_t {
    unsigned short data[4];
};

/* global gdt, defined in kernel.s */
extern struct descriptor_t gdt[8];

struct ldt_t {
    struct descriptor_t null;
    struct descriptor_t code;
    struct descriptor_t data;
};

enum task_state {
    TASK_READY,
    TASK_RUNNING,
};

struct tss_t {
    unsigned long link;
    unsigned long esp0, ss0, esp1, ss1, esp2, ss2;
    unsigned long cr3;
    unsigned long eip, eflags, eax, ecx, edx, ebx, esp, ebp, esi, edi;
    unsigned long es, cs, ss, ds, fs, gs;
    unsigned long ldt;
    unsigned long trace_bitmap;
};

struct task_t {
    unsigned int t_id;              /* task id */
    unsigned int t_counter;         /* used time slices */
    unsigned int t_priority;        /* task priority, higher to get more slices */
    struct tss_t *t_tss;
    struct descriptor_t t_ldt[3];   /* local descriptor table, 0:null,1:code,2:data */
    enum task_state t_state;        /* task state */
    int t_stack[TASK_STACK_SIZE];   /* task kernel stack */
};

/**
 * init_schedule()
 * initialize the scheduler
 */
void init_schedule();

/**
 * do_timer()
 * timer interrupt handler
 */
void do_timer();

/**
 * schedule()
 * select a task to run
 */
void schedule();

/**
 * register_task(void (*fn)(void))
 * @param fn: new task to register
 */
int register_task(void (*fn)(void));

void set_ldt_gate(int nr, long base, int dpl, long limit);
void set_tss_gate(int nr, long base, int dpl, long limit);

/**
 * delay(unsigned int delay)
 * @param delay: cycles to delay
 */
void delay(unsigned int delay);

#endif