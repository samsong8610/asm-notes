# asm-notes

The examples in assembly and C related to the Linux kernel code.

## How to make

```bash
cd <sub directory>
make
```

## 示例简介

- protected-mode

这个示例演示32位保护模式下段的使用。程序包含16位的启动程序，占用一个扇区，由bios加载到0x7c00处开始执行。然后初始化了两个保护模式下的段，特权级都是0，并跳转到代码段执行。有关保护模式的一点个人理解，可以移步[这篇博客](http://blog.samsong.online/assembly/protected-mode/2017/07/06/configure-protected-mode-in-x86.html)。

- interrupts

这个示例演示了通过中断实现系统调用的方法。例子中的kernel也链接了一个应用程序，运行在level 3特权级，它使用kernel定义的0x21中断输出一个字符。

- timer

这个示例演示了系统的时针tick实现方法。内核设置了100Hz的时针中断，应用程序根据这个时针中断输出系统运行秒数的计数。

- multi_task

这个示例演示了通过x86提供的多任务支持实现两个任务分时运行，分别输出1和2。实现要点在于正确设置TSS（Task State Segment）数据，每个任务一个，用于记录被切换任务的当前状态以便以后恢复。需要注意，如果发生特权级切换即使不使用TSS实现多任务也需要设置一个TSS，以便处理器获取高特权级的栈。

kernel2.s是只使用汇编实现的版本，如果要编译它需要修改Makefile，设置OBJS=kernel2.o