#include "schedule.h"

struct task_t *current;                 /* current task */
unsigned int tasks_count;               /* total tasks */
struct tss_t tsses[TASK_NR];            /* TSS for tasks */
struct task_t tasks[TASK_NR];           /* task control blocks */

static void switch_to(int next);

void init_schedule() {
    current = (struct task_t *)0;
    tasks_count = 0;
    register_task(0);
    tasks[0].t_counter = 0;
    tasks[0].t_priority = 0;
    current = &tasks[0];
    asm volatile ("pushfl; andl $0xffffbfff, (%esp); popfl");   /* clear NT */
    asm volatile ("ltr %%ax"::"a"(_TSS(0)));
    asm volatile ("lldt %%ax"::"a"(_LDT(0)));
}

void do_timer() {
    if (tasks_count <= 1) {
        return;
    }
    if (current != &tasks[0]) {
        current->t_counter--;
    }
    if (current->t_counter == 0) {
        schedule();
    }
}

void schedule() {
    int i;
    int next = -1;
    struct task_t *p = (struct task_t*)0;

repeat:
    for (i = 0; i < tasks_count; i++) {
        if (tasks[i].t_state == TASK_READY
            && tasks[i].t_counter > 0
            && (!p || tasks[i].t_counter > p->t_counter)) {
            next = i;
            p = &tasks[i];
        }
    }
    if (next == -1) {
        for (i = 0; i < tasks_count; i++) {
            tasks[i].t_state = TASK_READY;
            tasks[i].t_counter = tasks[i].t_priority;
        }
        goto repeat;
    }
    switch_to(next);
}

int register_task(void (*fn)(void)) {
    if (tasks_count > TASK_NR) return -1;
    tasks[tasks_count].t_id = tasks_count;
    /* init ldt */
    tasks[tasks_count].t_ldt[0].data[0] = 0;
    tasks[tasks_count].t_ldt[0].data[1] = 0;
    tasks[tasks_count].t_ldt[0].data[2] = 0;
    tasks[tasks_count].t_ldt[0].data[3] = 0;
    tasks[tasks_count].t_ldt[1].data[0] = 0x00ff;
    tasks[tasks_count].t_ldt[1].data[1] = 0;
    tasks[tasks_count].t_ldt[1].data[2] = 0xfa00;     /* code segment */
    tasks[tasks_count].t_ldt[1].data[3] = 0x00c0;
    tasks[tasks_count].t_ldt[2].data[0] = 0x00ff;
    tasks[tasks_count].t_ldt[2].data[1] = 0;
    tasks[tasks_count].t_ldt[2].data[2] = 0xf200;     /* data segment */
    tasks[tasks_count].t_ldt[2].data[3] = 0x00c0;
    set_ldt_gate(tasks_count, (long)tasks[tasks_count].t_ldt, 3, 23); 

    /* init tss */
    tsses[tasks_count].link = 0;
    tsses[tasks_count].esp0 = &tasks[tasks_count].t_stack[TASK_STACK_SIZE - 1];
    tsses[tasks_count].ss0 = 0x10;
    tsses[tasks_count].esp1 = 0;
    tsses[tasks_count].ss1 = 0;
    tsses[tasks_count].esp2 = 0;
    tsses[tasks_count].ss2 = 0;
    tsses[tasks_count].cr3 = 0;
    tsses[tasks_count].eip = (unsigned long)fn;
    tsses[tasks_count].eflags = 0x200;
    tsses[tasks_count].eax = 0;
    tsses[tasks_count].ecx = 0;
    tsses[tasks_count].edx = 0;
    tsses[tasks_count].ebx = 0;
    tsses[tasks_count].esp = 0x9ffff - (tasks_count << 16);
    tsses[tasks_count].ebp = 0;
    tsses[tasks_count].esi = 0;
    tsses[tasks_count].edi = 0;
    tsses[tasks_count].es = 0x17;
    tsses[tasks_count].cs = 0x0f;
    tsses[tasks_count].ds = 0x17;
    tsses[tasks_count].ss = 0x17;
    tsses[tasks_count].fs = 0x17;
    tsses[tasks_count].gs = 0x17;
    tsses[tasks_count].ldt = _LDT(tasks_count);
    tsses[tasks_count].trace_bitmap = 0x8000000;
    set_tss_gate(tasks_count, (long)&tsses[tasks_count], 3, 103);

    /* init task */
    tasks[tasks_count].t_counter = 2;
    tasks[tasks_count].t_priority = 2;
    tasks[tasks_count].t_tss = &tsses[tasks_count];
    tasks[tasks_count].t_state = TASK_READY;
    tasks_count++;
}

void set_ldt_gate(int nr, long base, int dpl, long limit) {
    char *addr = ((char*)gdt) + _LDT(nr);
    *(short*)addr = limit;
    *(short*)(addr + 2) = base & 0xffff;
    *(addr + 4) = (base >> 16) & 0xff;
    *(addr + 5) = 0x80 + ((dpl & 0x03) << 5) + 0x02;
    *(addr + 6) = 0x00;
    *(addr + 7) = (base >> 24) & 0xff;
}

void set_tss_gate(int nr, long base, int dpl, long limit) {
    char *addr = ((char*)gdt) + _TSS(nr);
    *(short*)addr = limit;
    *(short*)(addr + 2) = base & 0xffff;
    *(addr + 4) = (base >> 16) & 0xff;
    *(addr + 5) = 0x80 + ((dpl & 0x03) << 5) + 0x09;
    *(addr + 6) = 0x00;
    *(addr + 7) = (base >> 24) & 0xff;
}

void delay(unsigned int delay) {
    while (delay--) ;
}

static void switch_to(int next) {
    struct {long a,b;} tmp;
    if (&tasks[next] == current) {
        return ;
    }
    if (current) {
        current->t_state = TASK_READY;
    }
    current = &tasks[next];
    current->t_state = TASK_RUNNING;
    tmp.b = _TSS(next);
    asm volatile (
        "ljmp %0"
        ::"m"(*&tmp.a)
    );
}