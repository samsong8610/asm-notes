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

这个示例演示了通过中断实现系统调用的方法。例子中的kernel也链接了一个应用程序，它使用kernel定义的0x21中断输出一个字符。
