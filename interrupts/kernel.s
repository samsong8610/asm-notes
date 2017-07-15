/*
 * kernel.s
 * Setup data segment and stack, register property interrupts then run application
 * This code will be compiled with gnu assembler
*/

.text
.globl gdt, idt, startup, main

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
    /* reset all segments after changing gdt */
    xor %eax, %eax
    mov $0x10, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    mov $0x9ffff, %esp

    /* init put_char system call */
    lea sys_put_char, %edx
    mov $0x00080000, %eax           /* select kernel code segment */
    mov %dx, %ax                    /* ax: handler address low 16 bits */
    mov $0x8e00, %dx                /* dpl=0, interrupt gate */
    mov $33, %ecx                   /* int 0x21: put a char(al) to the screen */
    lea idt(,%ecx,8), %edi
    mov %eax, (%edi)
    mov %edx, 4(%edi)

    sti                             /* enable interrupt */

/*
    mov $80, %ecx
    mov $0x9c32, %ax
1:
    int $0x21
    dec %ecx
    jne 1b
    */

switch:
    /* switch to level 3 */
    xor %eax, %eax
    mov $0x20, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    mov $0x8ffff, %esp
    call $0x18, $main

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

    .align 8
gdt:
    .quad 0                     /* null descriptor */
    .quad 0x00c09a00000000ff    /* kernel code segment, base 0x0, limit 0xff(size 1M), DPL=0 */
    .quad 0x00c09200000000ff    /* kernel data segment, base 0x0, limit 0xff(size 1M), DPL=0 */
    .quad 0x00c09a00000000ff    /* app code segment, base 0x0, limit 0xff(size 1M), DPL=0 */
    .quad 0x00c09200040000ff    /* app data segment, base 0x0, limit 0xff(size 1M), DPL=0 */

gdtr_value:
    .word 8*5 - 1               /* base + limit is the address of the LAST byte, so minus 1 */
    .long gdt

    .align 8
idt:
    .fill 34,8,0                /* only set 34 idt descriptors, each is 8 bytes */

idtr_value:
    .word 8*34 - 1
    .long idt

pos:
    .long 0                     /* current output position on screen */
