/*
 * kernel.s
 * Setup data segment and stack, register property interrupts then run application
 * This code will be compiled with gnu assembler
*/

.text
.globl gdt, idt, startup, main, pos, jiffies

    .equ HZ, 100                    /* 10ms per jiffy */
    .equ LATCH, 1193182/HZ          /* counter value */

startup:
    xor %eax, %eax
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    mov $0x9ffff, %esp
    call setup_idt
    call setup_gdt
    jmp $0x08, $gdt_ok
gdt_ok:
    /* reset all segments after changing gdt */
    xor %eax, %eax
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    mov $0x9ffff, %esp

    call setup_timer
    /* init put_char system call */
    lea sys_put_char, %edx
    mov $0x00080000, %eax           /* select kernel code segment */
    mov %dx, %ax                    /* ax: handler address low 16 bits */
    mov $0xee00, %dx                /* dpl=3, allow level 3 app invoke, interrupt gate */
    mov $0x21, %ecx                 /* int 0x21: put a char(al) to the screen */
    lea idt(,%ecx,8), %edi
    mov %eax, (%edi)
    mov %edx, 4(%edi)
    /* init invalid tss exception handler */
    lea invalid_tss_handler, %edx
    mov $0x0a, %ecx
    call set_idt_gate
    /* init stack fault exception handler */
    lea stack_fault_handler, %edx
    mov $0x0c, %ecx
    call set_idt_gate
    /* init general protection handler */
    lea general_protection_handler, %edx
    mov $0x0d, %ecx
    call set_idt_gate

kernel_start:
    mov $0x9c32, %ax
    int $0x21
    call put_char

    pushfl
    andl $0xffffbfff, (%esp)            /* clear NT */
    popfl
    mov $0x18, %eax
    ltr %ax
    mov $0x20, %eax
    lldt %ax
    xor %eax, %eax
    movl %eax, current
    sti

    push $0x17
    push $user_stack0
    pushf
    push $0x0f
    push $task0
    iret

endless:
    jmp endless

/*
 * setup_gdt
 * setup gdt for kernel and app
 */
setup_gdt:
    lgdt gdtr_value
    ret

/*
 * setup_idt
 * setup default idt
 */
setup_idt:
    lea default_int_handler, %edx   /* handler address */
    mov $0x00080000, %eax           /* select kernel code segment */
    mov %dx, %ax                    /* ax: handler address low 16 bits */
    mov $0x8e00, %dx                /* dpl=0, interrupt gate */
    mov $34, %ecx
    lea idt, %edi
1:
    mov %eax, (%edi)                /* interrupt gate low 16 bits */
    mov %edx, 4(%edi)               /* interrupt gate high 16 bits */
    add $8, %edi
    dec %ecx
    jne 1b
    lidt idtr_value                 /* load idt */
    ret

/*
 * default_int_handler
 * default interrupt handler, output a char 'C'
 */
default_int_handler:
    push %ds
    pushl %eax
    mov $0x10, %ax                  /* use kernel data segment */
    mov %ax, %ds
    mov $0x9c43, %ax                    /* output 'C' */
    call put_char
    popl %eax
    pop %ds
    iret

invalid_tss_handler:
    /* print '10' for 0x0a interrupt number */
    pop %eax                        /* pop error code */
    mov $0x9c31, %ax
    call put_char
    mov $0x9c30, %ax
    call put_char
    mov $0x0720, %ax
    call put_char
    iret

stack_fault_handler:
    /* print '12' */
    pop %eax                        /* pop error code */
    mov $0x9c31, %ax
    call put_char
    mov $0x9c32, %ax
    call put_char
    mov $0x0720, %ax
    call put_char
    iret

general_protection_handler:
    /* print '13' */
    pop %eax                        /* pop error code */
    mov $0x9c31, %ax
    call put_char
    mov $0x9c33, %ax
    call put_char
    mov $0x0720, %ax
    call put_char
    iret

sys_put_char:
    push %ds
    pushl %edx
    pushl %ecx
    pushl %ebx
    pushl %eax
    mov $0x10, %dx
    mov %dx, %ds
    call put_char
    popl %eax
    popl %ebx
    popl %ecx
    popl %edx
    pop %ds
    iret

put_char:
    pushl %ebx
    pushl %ecx
    mov $0xb8000, %ebx
    mov pos, %ecx
    /* mov $0x07, %ah */
    mov %ax, (%ebx,%ecx,2)
    inc %ecx
    cmp $2000, %ecx
    jne 1f
    mov $0, %ecx
1:
    mov %ecx, pos
    popl %ecx
    popl %ebx
    ret

/*
 * set interrupt gate
 * edx: interrupt handler entrypoint address
 * ecx: interrupt number
 */
set_idt_gate:
    push %eax
    push %edi
    mov $0x00080000, %eax
    mov %dx, %ax
    mov $0x8e00, %dx
    lea idt(,%ecx,8), %edi
    mov %eax, (%edi)
    mov %edx, 4(%edi)
    pop %edi
    pop %eax
    ret

/*
 * setup a timer to generate jiffies
 */
setup_timer:
    pushl %edx
    pushl %eax
    pushl %ecx
    pushl %edi
    lea timer_handler, %edx
    mov $0x00080000, %eax           /* select kernel code segment */
    mov %dx, %ax                    /* ax: handler address low 16 bits */
    mov $0x8e00, %dx                /* dpl=0, interrupt gate */
    mov $0x08, %ecx
    lea idt(,%ecx,8), %edi          /* BIOS set timer interrupt at 0x08, use it directly */
    mov %eax, (%edi)
    mov %edx, 4(%edi)

    /* configure timer */
    mov $0x36, %al                  /* bit0=0: binary count value; bit1-3=b011: square wave;
                                     * b4-5=16bit value; bit6-7=0: channel 0(port 0x40) */
    mov $0x43, %dx                  /* timer command register port */
    out %al, %dx
    mov $LATCH, %ax                 /* init counter value */
    /* mov $11932, %ax                init counter value */
    mov $0x40, %dx                  /* channel 0 data register port */
    out %al, %dx                    /* lobyte first */
    mov %ah, %al                    /* hibyte next */
    out %al, %dx
    popl %edi
    popl %ecx
    popl %eax
    popl %edx
    ret

/*
 * timer interrupt handler
 */
timer_handler:
    push %eax
    push %ebx
    push %ecx
    push %edx
    push %edi
    push %esi
    mov $0x20, %al                  /* send the EOI to enable other interrupts */
    out %al, $0x20
    incl jiffies
    call do_timer
    pop %esi
    pop %edi
    pop %edx
    pop %ecx
    pop %ebx
    pop %eax
    iret

do_timer:
    xor %eax, %eax
    movl $1, %eax
    cmp %eax, current
    je 1f
    mov %eax, current
    ljmp $0x28, $0
    jmp 2f
1:
    movl $0, current
    ljmp $0x18, $0
2:
    ret

    .align 8
gdt:
    .quad 0                     /* null descriptor */
    .quad 0x00c09a00000000ff    /* kernel code segment, base 0x0, limit 0xff(size 1M), DPL=0 */
    .quad 0x00c09200000000ff    /* kernel data segment, base 0x0, limit 0xff(size 1M), DPL=0 */
    .word 0x67, tss0, 0xe900, 0x0   /* tss0 sel: 0x18 */
    .word 0x17, ldt0, 0xe200, 0x0   /* ldt0 sel: 0x20 */
    .word 0x67, tss1, 0xe900, 0x0   /* tss1 sel: 0x28 */
    .word 0x17, ldt1, 0xe200, 0x0   /* ldt1 sel: 0x30 */
gdt_end:

gdtr_value:
    .word gdt_end - gdt - 1     /* base + limit is the address of the LAST byte, so minus 1 */
    .long gdt

    .align 8
idt:
    .fill 34,8,0                /* only set 34 idt descriptors, each is 8 bytes */

idtr_value:
    .word 8*34 - 1
    .long idt

    .align 8
ldt0:
    .quad 0                     /* null descriptor */
    .quad 0x00c0fa00000003ff    /* task0 code */
    .quad 0x00c0f200000003ff    /* task0 data */
tss0:
    .long 0                     /* link */
    .long kernel_stack0, 0x10   /* esp0, ss0 */
    .long 0, 0, 0, 0, 0         /* esp1, ss1, esp2, ss2, cr3 */
    .long task0, 0x200, 0, 0, 0         /* eip, eflags, eax, ecx, edx */
    .long 0, user_stack0, 0, 0, 0         /* ebx, esp, ebp, esi, edi */
    .long 0x17, 0x0f, 0x17, 0x17, 0x17, 0x17         /* es, cs, ss, ds, fs, gs */
    .long 0x20, 0x8000000       /* ldt, trace bitmap */

    .fill 128, 4, 0             /* kernel stack for task 0 */
kernel_stack0:

    .align 8
ldt1:
    .quad 0                     /* null descriptor */
    .quad 0x00c0fa00000003ff    /* task0 code */
    .quad 0x00c0f200000003ff    /* task0 data */
tss1:
    .long 0                     /* link */
    .long kernel_stack1, 0x10   /* esp0, ss0 */
    .long 0, 0, 0, 0, 0         /* esp1, ss1, esp2, ss2, cr3 */
    .long task1, 0x200, 0, 0, 0         /* eip, eflags, eax, ecx, edx */
    .long 0, user_stack1, 0, 0, 0         /* ebx, esp, ebp, esi, edi */
    .long 0x17, 0x0f, 0x17, 0x17, 0x17, 0x17         /* es, cs, ss, ds, fs, gs */
    .long 0x30, 0x8000000       /* ldt, trace bitmap */

    .fill 128, 4, 0             /* kernel stack for task 0 */
kernel_stack1:

pos:
    .long 0                     /* current output position on screen */
jiffies:
    .long 0                     /* kernel jiffies */
current:
    .long 0                     /* current task */

task0:
    mov $0x17, %ax
    mov %ax, %ds
    mov $0x0741, %ax
    int $0x21
    mov $0xfff, %ecx
1:  loop 1b
    jmp task0

task1:
    mov $0x17, %ax
    mov %ax, %ds
    mov $0x9c42, %ax
    int $0x21
    mov $0xfff, %ecx
1:  loop 1b
    jmp task1

    .fill 128, 4, 0
user_stack0:
    .fill 128, 4, 0
user_stack1:
